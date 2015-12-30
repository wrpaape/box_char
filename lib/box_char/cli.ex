defmodule BoxChar.CLI do
  alias IO.ANSI
 # File.stream!(path, [:read, :char_list, encoding: :unicode], :line)   
  @def_opts Application.get_env(:box_char, :def_opts)

  @help_parse_opts [switches: [help: :boolean],
                    aliases:  [h:    :help]]

  @main_parse_opts [switches: [map: :boolean, swap: :boolean, light: :boolean, heavy: :boolean, double: :boolean, all: :boolean],
                    aliases:  [m:   :map,     s:    :swap,    l:     :light,   h:     :heavy,   d:      :double,  a:   :all]]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  #external API ^

  def parse_args(argv) do
    argv
    |> OptionParser.parse_head(@help_opts)
    |> case do
      {[help: true], _, _}          -> :help
       
      {_, [path_str | rem_argv], _} ->
        path_str
        |> Path.wildcard
        |> Enum.filter(&File.regular?/1)
        |> case do
          []    -> {:error, "path", argv} 

          files -> parse_args(rem_argv, files)
        end
    end
  end

  def parse_args(argv, files) do
    argv
    |> OptionParser.parse(@main_parse_opts)
    |> case do
      {[], [], _} -> {:erroor, "too many args!"}

      {opts, rem_argv, _} -> {opt_val, rem_argv}

      ________________________________ -> :error
    end
  end



  def parse_next([last_arg], [], opts_tup), do: opts_tup

  def parse_next([], [], opts_tup), do: opts_tup

  def process(:help) do
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
