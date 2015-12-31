defmodule GenError.Behaviour do
  alias IO.ANSI

  def highlight_invalid, do: "\n  " <> ANSI.bright <> ANSI.white_background

  defmacro error(reason, msg) when is_atom(reason) and is_binary(msg) do
    quote do
      def exception(reason) do
        unquote(msg)
        |> put_msg
      end
    end
  end

  defmacro error_with_arg(reason, fun = {anon, _, _}) when is_atom(reason) and anon in ~w(fn &)a do
    quote do
      def exception({reason, arg}) do
        unquote(fun)
        |> apply([arg])
        |> put_msg
      end
    end
  end

  defmacro error_with_arg(reason, msg) when is_atom(reason) do 
    quote do
      def exception({reason, arg}) do
        [unquote(msg), ":", highlight_invalid, arg]
        |> Enum.join
        |> put_msg
      end
    end
  end

  defmacro put_msg(msg), do: quote do: %__MODULE__{message: unquote(msg)}
end
