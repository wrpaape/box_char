defmodule BoxChar.CLI do
  alias IO.ANSI
 # File.stream!(path, [:read, :char_list, encoding: :unicode], :line)   
  @def_path Application.get_env(:box_char, :def_path)
  @def_opts Application.get_env(:box_char, :def_opts)

  @mode_parse_opts [switches: [help: :boolean, map: :string, swap: :string],
                    aliases:  [h:    :help,    m:   :map,    s:    :swap]]

  @type_parse_opts [switches: [light: :boolean, heavy: :boolean, double: :boolean, all: :boolean],
                    aliases:  [l:     :light,   h:     :heavy,   d:      :double,  a:   :all]]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  #external API ^

  def parse_args(argv) do
    argv
    |> OptionParser.parse(@parse_opts)
    |> case do
      {[help: true], ________, _______} ->
        |> print_help_and_halt

      {[], _____________, ____________} ->
        "please specify <mode> of operation"
        |> handle_error
       
      {[{mode, spec_str}], rem_argv, _} ->
        rem_argv
        |> parse_path
        |> validate_path
        |> extract_files
        |> parse_spec(spec_str) 
        |> validate_spec(mode)

        _______________________________ -> 
        "too many args!"
        |> handle_error
    end
  end

  def parse_path([path_str]), do: {Path.wildcard(path_str),path_str} 
  def parse_path([]),         do: handle_error("please specify <path> to file or populated directory")
  def parse_path(_),          do: handle_error("too many args!") 

  def validate_path({[], path_str}),        do: handle_error("invalid path: " <> path_str)
  def validate_path({path_glob, path_str}), do: {Enum.filter(path_glob, &File.regular?/1), path_str}

  def extract_files({[], path_str}), do: handle_error("failed to find file(s) at path: " <> path_str)
  def extract_files({files, _}),     do: files

  def parse_spec(files, spec_str) do
    spec_str
    |> String.split("/")
    |> OptionParser.parse(@spec_parse_opts)
  end



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
