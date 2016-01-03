defmodule BoxChar.Swapper.Initializer do
  @swap_map Application.get_env(:box_char, :swap_map) 

  defmacro define_swap_next_functions do
    quote [bind_quoted: [swap_map: @swap_map]] do 
      swap_map
      |> Enum.each(fn([old_set, new_set, old_char, new_char])->

        def swap_next(unquote(old_set), unquote(new_set), unquote(old_char) <> rem_str, acc_str) do
          unquote(old_set)
          |> swap_next(unquote(new_set), rem_str, acc_str <> unquote(new_char))
        end
      end)

      def swap_next(old_set, new_set, << no_match :: binary-size(1) >> <> rem_str, acc_str) do
        old_set
        |> swap_next(new_set, rem_str, acc_str <> no_match)
      end

      def swap_next(_, _, "", acc_str), do: acc_str
    end
  end
end
