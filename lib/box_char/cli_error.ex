defmodule BoxChar.CLIError do
  use GenError 

  error_with_arg :invalid_path
  error_with_arg :no_files_found
  error_with_arg :invalid_charset

  error_with_arg :invalid_args, fn(args)->
    args
    |> Enum.reduce(retrieve_msg(:invalid_args) <> ":", fn({arg, _}, msg)->
      msg
      <> emphasize(arg)
    end)
  end
end
