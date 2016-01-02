defmodule BoxChar.CLI do
  alias BoxChar.CLI.ArgVError
  alias BoxChar.CLI.UsageError

  import BoxChar.CLI.Initializer

  define_parse_charset_functions

  @usage         Application.get_env(:box_char, :usage)
  @spec_delim    Application.get_env(:box_char, :spec_delim)
  @parse_opts    Application.get_env(:box_char, :parse_opts)
  @timeout       Application.get_env(:box_char, :timeout)
  # @file_stream_modes [:read, :char_list, encoding: :unicode]
  # @charset_parse_opts [strict:  [light: :boolean, heavy: :boolean, double: :boolean, all: :boolean],
  #                      aliases: [l:     :light,   h:     :heavy,   d:      :double,  a:   :all]]

  def main(argv) do
    argv
    |> OptionParser.parse(@parse_opts)
    |> handle_parse
    |> BoxChar.process
    
    # Mix.env
    # |> handle_shutdown
  end

  #external API ^

  def handle_parse({[help: true], _, _}),      do: {:help, @usage} 
  def handle_parse({[{mode, spec_str}], rem_argv, []}) do
    rem_argv
    |> parse_path
    |> parse_spec(spec_str)
    |> handle_mode(mode)
  end

  def handle_parse({[], _, []}),               do: raise(UsageError, :missing_mode)
  def handle_parse({_, _, []}),                do: raise(UsageError, :multiple_modes)
  def handle_parse({_, _, args}),              do: raise(ArgVError, {:unknown_options, strip_unknowns(args)})


  def parse_path([path_str]) do
    path_str
    |> Path.wildcard
    |> handle_path(path_str)
  end

  def parse_path([]),        do: raise(UsageError, :missing_path)
  def parse_path(_),         do: raise(UsageError, :extra_args) 
  
  def handle_path([], path_str),       do: raise(ArgVError, {:invalid_path, path_str})
  def handle_path(path_glob, path_str) do
    path_glob
    |> Enum.filter(&File.regular?/1)
    |> parse_file_paths(path_str)
  end

  def parse_file_paths([], path_str),  do: raise(ArgVError, {:no_files_found, path_str})
  def parse_file_paths(file_paths, _), do: file_paths

  def parse_spec(files, spec_str) do
    spec_str
    |> String.split(@spec_delim, trim: true)
    |> handle_spec(files, spec_str)
  end

  def handle_spec([], _, spec_str),  do: {:empty, spec_str}
  def handle_spec([_], _, spec_str), do: {:missing, spec_str}
  def handle_spec(spec, files, _),   do: {files, spec}

  def handle_mode({:empty, spec_str}, :map),     do: raise(UsageError, {:invalid_escapes, spec_str})
  def handle_mode({:missing, spec_str}, :map),   do: raise(UsageError, {:no_delim_escapes, spec_str})
  def handle_mode({files, [open, close]}, :map), do: {:map, files, open, close}
  def handle_mode(_, :map),                      do: raise(UsageError, :delim_in_escapes)
  def handle_mode({:empty, spec_str}, :swap),    do: raise(UsageError, {:invalid_charsets, spec_str})
  def handle_mode({:missing, spec_str}, :swap),  do: raise(UsageError, {:no_delim_charsets, spec_str})
  def handle_mode({_, [str, str]}, :swap),       do: raise(UsageError, :same_swap_charsets)
  def handle_mode({files, charset_strs}, :swap)  do
    charset_strs
    |> Enum.map(&parse_charset/1)
    |> handle_charsets(files)
  end

  def handle_charsets([_], _),             do: raise(UsageError, :missing_swap_charset) 
  def handle_charsets([same, same], _),    do: raise(UsageError, :same_swap_charsets) 
  def handle_charsets([_, :all], _),       do: raise(UsageError, :swap_new_charset_all) 
  def handle_charsets([old, new], files),  do: {:swap, files, old, new}
  def handle_charsets(_, _),               do: raise(UsageError, :extra_swap_charsets) 

  # def handle_parse(charsets, :map, files), do: {:map, files, filter_next([], charsets, HashSet.new)}

  # def filter_next(_, [:all | _], _),       do: [:all]
  # def filter_next(acc, [], _),             do: acc
  # def filter_next(acc, [next | rem], dups) do
  #   dups
  #   |> HashSet.member?(next)
  #   |> handle_dup(next, acc, rem, dups)
  # end

  # def handle_dup(false, next, acc, rem, dups), do: filter_next([next | acc], rem, HashSet.put(dups, next))
  # def handle_dup(_, _, acc, rem, dups),        do: filter_next(acc, rem, dups)

  def handle_shutdown(:test), do: exit(:normal)
  def handle_shutdown(_),     do: System.halt(0) 

  #helpers v  
  defp strip_unknowns(args), do: Enum.map(args, &elem(&1, 0))
end
