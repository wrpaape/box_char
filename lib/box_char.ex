defmodule BoxChar do
  alias BoxChar.Mapper
  alias BoxChar.Swapper

  def process({:help, msg}), do: IO.write(msg)
  def process({:swap, old_charset, new_charset, files}) do
    files
    |> Enum.each(fn(file)->
      Swapper
      |> spawn(:scan, [file, old_charset, new_charset])
    end)
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


  def write_to_file(contents, file), do: File.write!(file, contents)
end
