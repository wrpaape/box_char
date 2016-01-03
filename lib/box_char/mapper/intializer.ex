defmodule BoxChar.Mapper.Initializer do
  @char_map Application.get_env(:box_char, :char_map) 

  defmacro define_map_next_functions do
    quote [bind_quoted: [char_map: @char_map]] do 
      char_map
      |> Enum.each(fn({input, output})->
        def map_next(unquote(input) <> rem_str, acc_str) do
          rem_str
          |> map_next(acc_str <> unquote(output))
        end
      end)

      def map_next(<< no_match :: binary-size(1) >> <> rem_str, acc_str) do
        rem_str
        |> map_next(acc_str <> no_match)
      end

      def map_next("", acc_str), do: acc_str
    end
  end
end
