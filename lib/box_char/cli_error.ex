defmodule BoxChar.CLIError do
  use GenError 

  error_with_args :invalid_path,    "invalid path"
  error_with_args :invalid_args,    "invalid args"
  error_with_args :no_files_found,  "failed to find file(s) at path"
  error_with_args :invalid_charset, "invalid charset"
end
