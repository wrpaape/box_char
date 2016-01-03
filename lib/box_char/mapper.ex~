defmodule BoxChar.Mapper do
  use GenServer

  def start_link(escapes), do: GenServer.start_link(__MODULE__, escapes, name: __MODULE__)
  def split_open(string),  do: GenServer.call(__MODULE__, {:split_open, string})

  def split_close(string), do: GenServer.call(__MODULE__, {:split_close, string})

  def mend(string),        do: GenServer.call(__MODULE__, {:mend, string})

  # def scan_file(file_str), do: GenServer.call(__MODULE__, {:scan_file, file_str})



  def init({open_str, close_str}) do
    {:ok, {:binary.compile_pattern(open_str), :binary.compile_pattern(close_str), open_str}}
  end

  def handle_call({:scan_file, file_str}, _from, {open, close, open_str}) do

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
