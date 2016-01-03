defmodule BoxChar.Mapper.Intializer do

  @char_map Application.get_env(:box_char, :char_map) 
    |> Keyword.values

  defmacro define_map_next_functions do
    quote [bind_quoted: [char_map: @char_map]] do 
      char_map
      |> Enum.each(fn({charset, flags})->
        def parse_charset(charset_str) when charset_str in unquote(flags), do: unquote(charset)
      end)

      def parse_charset(charset_str), do: raise(ArgVError, {:invalid_charset, charset_str})
    end
  end
end
