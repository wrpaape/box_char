defmodule BoxChar.CLI.Initializer do
  alias BoxChar.CLI.ArgVError

  @charset_flags Application.get_env(:box_char, :charset_flags) 

  defmacro define_parse_charset_functions do
    quote [bind_quoted: [charset_flags: @charset_flags]] do 
      charset_flags
      |> Enum.each(fn({charset, flags})->
        def parse_charset(charset_str) when charset_str in unquote(flags), do: unquote(charset)
      end)

      def parse_charset(charset_str), do: raise(ArgVError, {:invalid_charset, charset_str})
    end
  end
end
