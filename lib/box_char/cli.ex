defmodule BoxChar.CLI do
  alias IO.ANSI
 # File.stream!(path, [:read, :char_list, encoding: :unicode], :line)   
  @def_opts Application.get_env(:box_char, :def_opts)
  # @parse_opts [
  #   mode: [
  #     switches: [help:   :boolean, swap:    :boolean, map:  :boolean],
  #     aliases:  [h:      :help,    s:       :swap,    m:    :map]
  #   ],
  #   num_lines: [
  #     switches: [single: :boolean, double: :boolean, both: :boolean],
  #     aliases:  [s:      :single,  d:       :double, b:    :both]
  #   ],
  #   line_weight: [
  #     switches: [light:  :boolean, heavy:   :boolean, both: :boolean],
  #     aliases:  [l:      :light,   h:       :heavy,   b:    :both]
  #   ]
  # ]
  @parse_opts [help: [switches: [help:  :boolean],
                      aliases:  [h:     :help]],

               mode: [switches: [map:   :boolean, swap:  :boolean],
                      aliases:  [m:     :map,     s:     :swap]],

               type: [switches: [light: :boolean, heavy: :boolean, double: :boolean, all: :boolean],
                      aliases:  [l:     :light,   h:     :heavy,   d:      :double,  a:   :all]]]

  def main(argv) do
    argv
    |> parse_args(@parse_opts)
    |> process
  end

  #external API ^

  def process({board_size, __}) when board_size in @min..@max, do: process(board_size)
  def process({_board_size, _}), do: alert("board size must be >= #{@min} and <= #{@max}")
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

  def process({:error, opt, rem_argv}) do
    """
    failed to parse <#{opt}> from:

      #{rem_argv}
    """
    |> alert(:red)

    process(:help)
  end


  def parse_args(argv, [{:help, help_parse_opts} | rem_parse_opts]) do
    argv
    |> OptionParser.parse_head(help_parse_opts)
    |> case do
      {[help: true], _, _}          -> :help
       
      {_, [path_str | rem_argv], _} ->
        path_str
        |> Path.wildcard
        |> Enum.filter(&File.regular?/1)
        |> case do
          []    -> {:error, "found no files in path: " <> path_str} 

          files -> parse_args(rem_argv, rem_parse_opts, [files])
        end
    end
  end

  def parse_args(argv, [{:mode, mode_parse_opts} | rem_parse_opts], parsed_opts) do
    argv
    |> OptionParser.parse_head(mode_parse_opts)
    |> case do
      {[{mode, true}], rem_argv, _} -> parse_args(rem_argv, rem_parse_opts, [mode | parsed_opts])

      _____________________________ -> {:error, "failed to parse mode"}
    end
  end

  def parse_args([], [], parse_opts), do: parsed_opts

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
