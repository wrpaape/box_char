defmodule BoxChar.CLIError do
  use GenError 

  error_with_arg :invalid_path
  error_with_arg :no_files_found
  error_with_arg :invalid_charset

  error_with_arg :invalid_args, fn(args)->
    [{retrieve_msg(:invalid_args)} | args]
    |> Enum.map_join(highlight_invalid, &elem(&1, 0))
  end
end
