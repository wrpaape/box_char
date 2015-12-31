defmodule BoxChar.CLI do
  alias IO.ANSI
  alias BoxChar.CLIError
  alias BoxChar.ArgVError

  @def_opts Application.get_env(:box_char, :def_opts)
  @timeout  Application.get_env(:box_char, :timeout)
  @usage    Application.get_env(:box_char, :usage)

  @parse_opts [strict:  [help: :boolean,  map:   :string,  swap:   :string],
               aliases: [h:    :help,     m:     :map,     s:      :swap]]

  @charset_parse_opts [strict:  [light: :boolean, heavy: :boolean, double: :boolean, all: :boolean],
                       aliases: [l:     :light,   h:     :heavy,   d:      :double,  a:   :all]]

  @file_stream_modes [:read, :char_list, encoding: :unicode]

  def main(argv) do
    try do
      argv
      |> OptionParser.parse(@parse_opts)
      |> handle_parse
      |> BoxChar.process
      
    catch
      :error, exception = %{message: msg} ->
        msg
        |> alert(:red)

        exception
        |> handle_exception

    after
      0
      |> System.halt
    end
  end

  #external API ^

  def handle_parse({[help: true], _, _}),      do: print_usage
  def handle_parse({[spec_tup], rem_argv, []}) do
    rem_argv
    |> parse_path
    |> parse_charset(spec_tup)
  end

  def handle_parse({[], _, _}),                do: raise(ArgVError, :missing_mode)
  def handle_parse({_, _, []}),                do: raise(ArgVError, :multiple_modes)
  def handle_parse({_, _, args}),              do: raise(CLIError, {:invalid_args, args})


  def parse_path([path_str]) do
    path_str
    |> Path.wildcard
    |> handle_parse(path_str)
  end

  def parse_path([]),        do: raise(ArgVError, :no_path)
  def parse_path(_),         do: raise(ArgVError, :extra_args) 


  def handle_parse([], path_str),       do: raise(CLIError, {:invalid_path, path_str})
  def handle_parse(path_glob, path_str) do
    path_glob
    |> Enum.filter(&File.regular?/1)
    |> parse_file_paths(path_str)
  end

  def parse_file_paths([], path_str),  do: raise(CLIError, {:no_files_found, path_str})
  def parse_file_paths(file_paths, _), do: file_paths

  def parse_charset(files, {mode, charset_str}) do
    charset_str
    |> String.split([" ", "/"], trim: true)
    |> Enum.map(&extract_charset/1)
    |> handle_parse(mode, files)
  end

  def extract_charset(charset_str) when charset_str in ~w(l light),  do: :light
  def extract_charset(charset_str) when charset_str in ~w(h heavy),  do: :heavy
  def extract_charset(charset_str) when charset_str in ~w(d double), do: :double
  def extract_charset(charset_str) when charset_str in ~w(a all),    do: :all
  def extract_charset(charset_str),                                  do: raise(CLIError, {:invalid_charset, charset_str})

  def handle_parse([_], :swap, _),                             do: raise(ArgVError, :missing_swap_charset) 
  def handle_parse([charset, charset], :swap, _),              do: raise(ArgVError, :same_swap_charsets) 
  def handle_parse([_, :all], :swap, _),                       do: raise(ArgVError, :swap_new_charset_all) 
  def handle_parse([old_charset, new_charset], :swap, files),  do: {:swap, files, old_charset, new_charset}
  def handle_parse(_, :swap, _),                               do: raise(ArgVError, :extra_swap_charsets) 

  def handle_parse(charsets, :map, files), do: {:map, files, filter_next([], charsets, HashSet.new)}

  def filter_next(_, [:all | _], _),       do: [:all]
  def filter_next(acc, [], _),             do: acc
  def filter_next(acc, [next | rem], dups) do
    dups
    |> HashSet.member?(next)
    |> handle_dup(next, acc, rem, dups)
  end

  def handle_dup(false, next, acc, rem, dups), do: filter_next([next | acc], rem, HashSet.put(dups, next))
  def handle_dup(_, _, acc, rem, dups),        do: filter_next(acc, rem, dups)

  # def process({:error, opt, argv}) do
  #  """
  #  failed to parse <#{opt}> from:

  #    #{argv}
  #  """
  #  |> alert(:red)

  #  process(:help)
  # end

  defp print_usage, do: alert(@usage, :blue)

  def handle_exception(%ArgVError{}), do: print_usage
  def handle_exception(%CLIError{}),  do: exit(:normal) 
  def handle_exception(_unhandled),   do: alert("\n** UNHANDLED EXCEPTION **", :blink_slow)

  #helpers v  

  defp alert(msg, ansi_fun), do: IO.puts(apply(ANSI, ansi_fun, []) <> msg <> ANSI.reset)
end
