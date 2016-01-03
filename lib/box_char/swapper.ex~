defmodule BoxChar.Swapper do

  import BoxChar.Swapper.Initializer

  define_swap_next_functions

  def scan(file, old, new) do
    old
    |> swap_next(new, File.read!(file), "")
    |> BoxChar.write_to_file(file)
  end
end
