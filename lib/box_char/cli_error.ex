defmodule BoxChar.CLIError do
  use GenError

  error :missing_swap_charset, "please specify <new charset> to swap to"
  error :extra_swap_charsets,  "may only swap one <charset> at a time"
  
  error :invalid_path,    path,    "invalid path"
  error :no_files_found,  path,    "failed to find file(s) at path"
  error :invalid_charset, charset, "invalid charset"

  error :invalid_args, args  do
    [{"invalid args:"} | args]
    |> Enum.map_join("\n  ", &elem(&1, 0))
    |> put_message
  end
end
