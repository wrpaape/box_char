defmodule BoxChar.CLI do
  alias IO.ANSI
  alias BoxChar.CLIError
  alias BoxChar.ArgVError

  @def_path Application.get_env(:box_char, :def_path)
  @def_opts Application.get_env(:box_char, :def_opts)
  @timeout  Application.get_env(:box_char, :timeout)

  @mode_parse_opts    [strict:  [help: :boolean,  map:   :string,  swap:   :string],
                       aliases: [h:    :help,     m:     :map,     s:      :swap]]

  @charset_parse_opts [strict:  [light: :boolean, heavy: :boolean, double: :boolean, all: :boolean],
                       aliases: [l:     :light,   h:     :heavy,   d:      :double,  a:   :all]]

  @file_stream_modes [:read, :char_list, encoding: :unicode]

  def main(argv) do
    try do
      argv
      |> OptionParser.parse(@mode_parse_opts)
      |> handle_parse
      |> process
      
    catch
      :error, exception = %{message: msg} ->
        msg
        |> alert(:red)

        exception
        |> handle_exception

    after
      @timeout -> System.halt(0)
    end
  end

  #external API ^

  def handle_parse({[help: true], _, _}),     do: print_usage_and_halt
  def handle_parse({[spec_tup], rem_argv, []) do
    rem_argv
    |> parse_path
    |> parse_charset(spec_tup)
  end

  def handle_parse({[], _, _}),               do: raise(ArgVError, :missing_mode)
  def handle_parse({_, _, []}),               do: raise(ArgVError, :multiple_modes)
  def handle_parse({_, _, args}),             do: raise(CLIError, {:invalid_args, args})


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
    |> OptionParser.parse(@charset_parse_opts)
    |> handle_parse(mode, files)
  end

  def handle_parse({[{old, true}, {new, true}], _, _}, :swap, _) do
  end

  def handle_parse({[_], _, _}, :swap, _),                       do: raise(CLIError, :missing_swap_charset)
  def handle_parse(_, :swap, _),                                 do: raise(CLIError, :extra_swap_charsets)



  def process({:error, opt, argv}) do
    """
    failed to parse <#{opt}> from:

      #{argv}
    """
    |> alert(:red)

    process(:help)
  end

  def process({[:swap, old_type, new_type], files})

  def print_usage_and_halt do
    """

    usage:

      box_char <path> map <charset>

    or

      box_char <path> map <charsets (slash delimited)>

    or

      box_char <path> swap <old charset>/<new charset>
    """
    |> alert(:blue)

    System.halt(0)
  end
  #helpers v  

  def handle_exception(%ArgVError{}), do: print_usage_and_halt
  def handle_exception(%CLIError{}),  do: System.halt(0)

  defmacrop alert(msg, color) do
    quote do
      apply(ANSI, unquote(color), [])
      <> unquote(msg)
      <> ANSI.reset
      |> IO.puts
    end
  end
end
