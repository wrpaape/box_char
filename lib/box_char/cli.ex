defmodule BoxChar.CLI do
  alias IO.ANSI

  @def_path Application.get_env(:box_char, :def_path)
  @def_opts Application.get_env(:box_char, :def_opts)

  @mode_parse_opts [strict:  [help: :boolean, map: :string, swap: :string],
                    aliases: [h:    :help,    m:   :map,    s:    :swap]]

  @spec_parse_opts [strict:  [light: :boolean, heavy: :boolean, double: :boolean, all: :boolean],
                    aliases: [l:     :light,   h:     :heavy,   d:      :double,  a:   :all]]

  @file_stream_modes [:read, :char_list, encoding: :unicode]
  @file_stream_modes [:read, :char_list, encoding: :unicode]

  def main(argv) do
    argv
    |> OptionParser.parse(@mode_parse_opts)
    |> handle_parse
    |> process
  end

  #external API ^

  def handle_parse({[help: true], _, _}),     do: print_help_and_halt
  def handle_parse({[], _, _}),               do: handle_error("please specify <mode> of operation")
  def handle_parse({[spec_tup], rem_argv, []) do
    rem_argv
    |> parse_path
    |> parse_spec(spec_tup)
  end

  def handle_parse({_, _, []}),               do: handle_error("too many modes!")
  def handle_parse({_, _, invalid_args}),     do
    ["invalid args:" | invalid_args]
    |> Enum.map_join("\n  ", &elem(&1, 0))
    |> handle_error
  end


  def parse_path([]),        do: handle_error("please specify <path> to file or populated directory")
  def parse_path([path_str]) do
    path_str
    |> Path.wildcard
    |> handle_parse(path_str)
  end

  def parse_path(_),         do: handle_error("too many args!") 


  def handle_parse([], path_str),       do: handle_error("invalid path: " <> path_str)
  def handle_parse(path_glob, path_str) do
    path_glob
    |> Enum.filter(&File.regular?/1)
    |> parse_file_paths(path_str)
  end

  def parse_file_paths([], path_str),  do: handle_error("failed to find file(s) at path: " <> path_str)
  def parse_file_paths(file_paths, _), do: file_paths

  def parse_spec(files, {mode, spec_str}) do
    spec_str
    |> String.split("/")
    |> OptionParser.parse(@spec_parse_opts)
    |> handle_parse(mode, files)
  end

  def handle_parse({_}, :map, _), do: handle_error("")


  def print_help_and_halt do
    """
    usage:

      box_char <path> map <type>

    or

      box_char <path> swap <old_type> <new_type>
    """
    |> alert(:blue)

    System.halt(0)
  end

  def process({:error, opt, argv}) do
    """
    failed to parse <#{opt}> from:

      #{argv}
    """
    |> alert(:red)

    process(:help)
  end

  def process({[:swap, old_type, new_type], files})

  #helpers v  


  defmacrop alert(msg, color) do
    quote do
      apply(ANSI, unquote(color), [])
      <> unquote(msg)
      <> ANSI.reset
      |> IO.puts
    end
  end
end
