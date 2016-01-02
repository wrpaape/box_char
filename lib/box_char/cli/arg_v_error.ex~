defmodule BoxChar.CLI.ArgVError do
  use GenError 

  @errors Application.get_env(:box_char, __MODULE__)

  error_with_arg :invalid_path,    get_msg(:invalid_path)
  error_with_arg :unknown_options, get_msg(:unknown_options)
  error_with_arg :invalid_charset, get_msg(:invalid_charset)
  error_with_arg :no_files_found,  get_msg(:no_files_found)

  defp get_msg(error), do: Keyword.get(@errors, error)
end
