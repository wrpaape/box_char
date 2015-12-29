defmodule BoxChar.CLI do
  alias IO.ANSI
 # File.stream!(path, [:read, :char_list, encoding: :unicode], :line)   
  @def_opts Application.get_env(:box_char, :def_opts)
  @parse_opts [
    switches: [
      help: :boolean,
      swap: :boolean,
      map:  :boolean,
    ],
    aliases:  [
      h: :help,
      m: :map,
      s: :swap
    ]
  ]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  #external API ^

  def process({board_size, __}) when board_size in @min..@max, do: process(board_size)
  def process({_board_size, _}), do: alert("board size must be >= #{@min} and <= #{@max}")
  def process(:error),           do: alert("failed to parse integeer from board size")
  def process(:help),            do: alert("usage: box_char <path> <mode> <char_set>", :blue)
  def process(board_size)        do
    board_size
    |> Board.start_link

    {wrap_dir, turn_str} =
      "heads or tails (h/t)?"
      |> Misc.str_app(@cursor)
      |> IO.gets
      |> String.match?(coin_flip_reg)
      |> if do: {:app, "first"}, else: {:pre, "second"}

    turn_str
    |> Misc.cap("you will have the ", " move.\nchoose a valid (not whitespace or a number) token character")
    |> Misc.str_app(@cursor)
    |> assign_tokens(wrap_dir)
    |> TicTacToe.start
  end

  def parse_args(argv) do
    argv
    |> OptionParser.parse(@parse_opts)
    |> case do
      {[help: true], _, _ }  -> :help
       
      {_, [], _}             -> @def_opts
 
      {_, [size_str | _], _} -> Integer.parse(size_str)
    end
  end

  #helpers v  

defmacrop alert(msg, color \\ :red) do
  quote do
    apply(ANSI, unquote(color), [])
    <> unquote(msg)
    <> ANSI.reset
    |> IO.puts

    System.halt(0)
  end
end
