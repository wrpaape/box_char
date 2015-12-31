defmodule BoxChar.CLIError do
  use GenError

  error :missing_swap_charset, "please specify <new charset> to swap to"
  error :extra_swap_charsets,  "may only swap one <charset> at a time"
  
  error_with_arg :invalid_path,    "invalid path"
  error_with_arg :no_files_found,  "failed to find file(s) at path"
  error_with_arg :invalid_charset, "invalid charset"

  error_with_arg :invalid_args, fn(args)->
    [{"invalid args:"} | args]
    |> Enum.map_join(highlight_invalid, &elem(&1, 0))
  end
end
