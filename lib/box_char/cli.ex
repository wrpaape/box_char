defmodule BoxChar.CLI do
  alias BoxChar.CLI.InputError
  alias BoxChar.CLI.UsageError

  import BoxChar.CLI.Initializer

  define_parse_charset_functions

  @usage         Application.get_env(:box_char, :usage)
  @spec_delim    Application.get_env(:box_char, :spec_delim)
  @parse_opts    Application.get_env(:box_char, :parse_opts)

  def main(argv) do
    argv
    |> OptionParser.parse(@parse_opts)
    |> handle_parse
    |> BoxChar.process
  end

  #external API ^

  def handle_parse({[], _, _}),                        do: raise(UsageError, :missing_mode)
  def handle_parse({[help: _], _, _}),                 do: {:help, @usage} 
  def handle_parse({[{mode, spec_str}], rem_argv, []}) do
    rem_argv
    |> parse_path
    |> parse_spec(spec_str)
    |> handle_mode(mode)
  end

  def handle_parse({_, _, []}),                        do: raise(UsageError, :multiple_modes)
  def handle_parse({_, _, args}),                      do: raise(InputError, {:unknown_options, strip_unknowns(args)})

  def parse_path([path_str]) do
    path_str
    |> Path.wildcard
    |> handle_path(path_str)
  end

  def parse_path([]),        do: raise(UsageError, :missing_path)
  def parse_path(_),         do: raise(UsageError, :extra_args) 
  
  def handle_path([], path_str),       do: raise(InputError, {:invalid_path, path_str})
  def handle_path(path_glob, path_str) do
    path_glob
    |> Enum.filter(&File.regular?/1)
    |> parse_file_paths(path_str)
  end

  def parse_file_paths([], path_str),  do: raise(InputError, {:no_files_found, path_str})
  def parse_file_paths(file_paths, _), do: file_paths

  def parse_spec(files, spec_str) do
    spec_str
    |> String.split(@spec_delim, trim: true)
    |> handle_spec(files, spec_str)
  end

  def handle_spec([_ | [_ | [_ | _]]], _, _), do: :extra
  def handle_spec([_], _, _),                 do: :missing
  def handle_spec([], _, str),                do: {:empty, str}
  def handle_spec(spec, files, _),            do: {files, spec}


  def handle_mode(:extra,           :map), do: raise(UsageError, :delim_in_escapes)
  def handle_mode(:missing,         :map), do: raise(UsageError, :no_delim_escapes)
  def handle_mode({:empty, str},    :map), do: raise(InputError, {:invalid_escapes, str})
  def handle_mode({files, escapes}, :map), do: {:map, escapes, files}

  def handle_mode(:extra,          :swap), do: raise(UsageError, :extra_swap_charsets) 
  def handle_mode(:missing,        :swap), do: raise(UsageError, :no_delim_charsets)
  def handle_mode({:empty, str},   :swap), do: raise(InputError, {:invalid_charsets, str})
  def handle_mode({_, [str, str]}, :swap), do: raise(UsageError, :same_swap_charsets)
  def handle_mode({files, strs},   :swap)  do
    strs
    |> Enum.map(&parse_charset/1)
    |> handle_charsets(files)
  end

  def handle_charsets([_], _),          do: raise(UsageError, :missing_swap_charset) 
  def handle_charsets([same, same], _), do: raise(UsageError, :same_swap_charsets) 
  def handle_charsets([_, :all], _),    do: raise(UsageError, :swap_new_charset_all) 
  def handle_charsets(charsets, files), do: {:swap, charsets, files}

  #helpers v  

  defp strip_unknowns(args), do: Enum.map(args, &elem(&1, 0))
end
