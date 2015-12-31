defmodule GenError.Behaviour do
  defmacro error(error, msg) do
    quote bind_quoted: [msg: msg] do
      def exception(error), do: %__MODULE__{message: msg}
    end
  end

  defmacro error(error, code, [do: block]) do
    quote bind_quoted: [code: code, block: block] do
      def exception({error, code}), do: %__MODULE__{message: block}
    end
  end
end
