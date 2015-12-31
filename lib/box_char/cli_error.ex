defmodule BoxChar.CLIError do
  use GenError

  error_with_arg :invalid_path,    "invalid path"
  error_with_arg :no_files_found,  "failed to find file(s) at path"
  error_with_arg :invalid_charset, "invalid charset"

  error_with_arg :invalid_args, fn(args)->
    [{"invalid args:"} | args]
    |> Enum.map_join(highlight_invalid, &elem(&1, 0))
  end
end
