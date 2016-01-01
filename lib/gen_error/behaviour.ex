defmodule GenError.Behaviour do
  alias IO.ANSI
  alias Mix.Utils

  def highlight_invalid, do: "\n  " <> ANSI.bright <> ANSI.white_background

  defmacro error(reason) when is_atom(reason) do
    quote do
      def exception(unquote(reason)) do
        unquote(reason)
        |> retrieve_msg
        |> put_msg
      end
    end
  end

  defmacro error_with_arg(reason, fun) when is_atom(reason) do
    quote do
      def exception({unquote(reason), arg}) do
        unquote(fun)
        |> apply([arg])
        |> put_msg
      end
    end
  end

  defmacro error_with_arg(reason) when is_atom(reason) do 
    quote do
      def exception({unquote(reason), arg}) do
        [retrieve_msg(unquote(reason)), ":", highlight_invalid, arg]
        |> Enum.join
        |> put_msg
      end
    end
  end

  defmacro put_msg(msg), do: quote do: %__MODULE__{message: unquote(msg)}

  defmacro retrieve_msg(reason) do
    quote do
      __MODULE__
      |> Module.split
      |> List.first
      |> Utils.underscore
      |> String.to_atom
      |> Application.get_env(:errors)
      |> get_in([__MODULE__, unquote(reason)])
    end
  end
end
