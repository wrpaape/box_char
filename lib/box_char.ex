defmodule BoxChar do
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

  # def process(args), do: IO.inspect(args)
  def process({:help, msg}), do: IO.write(msg)
  def process({:swap, old_charset, new_charset, files}) do
  end

  def process({:map, charsets, files}) do
  end
end
