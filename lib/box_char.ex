defmodule BoxChar do
  alias BoxChar.Mapper
  alias BoxChar.Swapper
  alias BoxChar.Supervisor

  @box_char %{
    thick:  %{
      lines: %{
        horiz: "═",
        vert:  "║"
      },
      joiners: %{
        top: "╦",
        mid: "╬",
        bot: "╩"
      },
      caps: %{
        top: %{left: "╔", right: "╗"},
        mid: %{left: "╠", right: "╣"},
        bot: %{left: "╚", right: "╝"}
      }
    },
    thin: %{
      lines: %{
        horiz: "─",
        vert:  "│"
      },
      joiners: %{
        top: "┬",
        mid: "┼",
        bot: "┴"
      },
      caps: %{
        top: %{left: "┌", right: "┐"},
        mid: %{left: "├", right: "┤"},
        bot: %{left: "└", right: "┘"}
      }
    }
  }

  # 123
  # qwe
  # asd
  #
  #
  #
  #
  #
  #

  def process({:help, msg}), do: IO.write(msg)
  def process({:swap, old_charset, new_charset, files}) do
  end

  def process({:map, open, close, files}) do
    open
    |> :binary.compile_pattern
    |> spawn_mappers(:binary.compile_pattern(close), open, files)
  end

  def spawn_mappers(open, close, open_str, files) do
    files
    |> Enum.each(fn(file)->
      Mapper
      |> spawn(:scan, [file, open, close, open_str])
    end)
  end


  def write_to_file(contents, file), do: IO.write(file, contents)
end
