defmodule GenError.Behaviour do
  alias IO.ANSI

  defmacro error(reason) when is_atom(reason) do
    quote do
      unquote(reason)
      |> error(unquote(default_msg(reason)))
    end
  end

  defmacro error(reason, msg) when is_atom(reason) do
    quote do
      def exception(unquote(reason)) do
        unquote(msg)
        |> put_msg
      end
    end
  end

  defmacro error_with_arg(reason) when is_atom(reason) do 
    quote do
      unquote(reason)
      |> error_with_arg(unquote(default_msg(reason)))
    end
  end

  defmacro error_with_arg(reason, msg) when is_atom(reason) do
    quote do
      def exception({unquote(reason), arg}) do
        unquote(msg)
        <> ":"
        <> emphasize(arg)
        |> put_msg
      end
    end
  end

  defmacro emphasize(arg) when is_list(arg) do
    quote do
      unquote(arg)
      |> Enum.map_join(&emphasize/1)
    end
  end

  defmacro emphasize(arg) do
    quote do
      "\n  "
      <> ANSI.bright
      <> ANSI.white_background
      <> inspect(unquote(arg))
      <> ANSI.reset
      <> ANSI.red
    end
  end

  defmacro put_msg(msg), do: quote do: %__MODULE__{message: unquote(msg)}

  defp default_msg(reason) when is_atom(reason) do
    reason
    |> to_string
    |> :binary.replace(:binary.compile_pattern(~w(- _)), " ", [:global])
  end
end
