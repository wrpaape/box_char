defmodule BoxChar.Mapper do

  import BoxChar.Mapper.Initializer

  define_map_next_functions

  def scan(file, open, close, open_str) do
    file
    |> File.open!(~w(read write)a, fn(file)->
      file
      |> IO.binread(:all)
      |> :binary.split(open)
      |> handle_split(open, close, open_str, "")
      |> BoxChar.write_to_file(file)
    end)
  end

  def handle_split([downstream], _, _, _, acc_file),         do: acc_file <> downstream
  def handle_split([upstream, downstream], open, close, open_str, acc_file) do
    downstream
    |> :binary.split(close)
    |> handle_close(upstream, open, close, open_str, acc_file)
  end

  def handle_close([downstream], upstream, _, _, open_str, acc_file) do
    acc_file <> upstream <> open_str <> downstream
  end

  def handle_close([input, downstream], upstream, open, close, open_str, acc_file) do
    downstream
    |> :binary.split(open)
    |> handle_split(open, close, open_str, acc_file <> map_next(input, ""))
  end
end
