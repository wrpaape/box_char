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
    |> Mapper.scan_files(:binary.compile_pattern(close), open, files)
  end

  def scan_map(file, {open_pat, open, close_pat}) do
    File.open!(file, ~w(read write)a, fn(file)->
      file
      |> IO.binread(:all)
      |> Mapper.scan_file
      |> write_to_file(file)
    end)
  end

  def map_next([downstream], _, {_, _, acc_file}),         do: acc_file <> downstream
  def map_next([upstream, downstream], close_pat, acc_tup) do
    downstream
    |> :binary.split(close_pat)
    |> handle_close(upstream, acc_tup)
  end

  def handle_close([downstream], upstream, {_, open, acc_file}) do
    acc_file <> upstream <> open <> downstream
  end

  def handle_close([map_chars, downstream], upstream, {open_pat, _, acc_file}) do

  end


  defp write_to_file(contents, file), do: IO.write(file, contents)
end
