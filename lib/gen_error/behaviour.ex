defmodule GenError.Behaviour do
  defmacro error(reason, msg) do
    quote do
      def exception(reason), do: %__MODULE__{message: unquote(msg)}
    end
  end

  defmacro error(reason, code, [do: block]) do
    quote do
      def exception({reason, unquote(code)}), do: %__MODULE__{message: unquote(block)}
    end
  end
end
