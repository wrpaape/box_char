defmodule GenError.Behaviour do
  alias IO.ANSI

  @highlight_invalid ":\n  " <> ANSI.bright <> ANSI.white_background

  defmacro error(reason, msg) do
    quote do
      def exception(reason), do: put_msg(unquote(msg))
    end
  end

  defmacro error(reason, code, [do: block]) do
    quote do
      def exception({reason, unquote(code)}), do: put_msg(unquote(block))
    end
  end

  defmacro error(reason, str, msg) do
    quote do
      def exception({reason, str}), do: put_msg(msg  <> @highlight_invalid <> str)
    end
  end

  defmacrop put_msg(msg), do: quote do: %__MODULE__{message: msg}
end
