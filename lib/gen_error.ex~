defmodule GenError do
  defmacro __using__(_opts) do
    quote do
      defexception [:message] 

      import GenError.Behaviour
    end
  end
end
