defmodule BoxChar.CLIError do
  defexception [:message]
  
  def exception(:missing_mode),           do: put_msg("please specify <mode> of operation")
  def exception(:multiple_modes),         do: put_msg("may only operate in one <mode> at a time")
  def exception(:missing_path),           do: put_msg("please specify <path> to file or populated directory")
  def exception(:extra_args),             do: put_msg("too many args!")
  def exception({:invalid_path, path}),   do: put_msg("invalid path:\n  " <> path)
  def exception({:no_files_found, path}), do: put_msg("failed to find file(s) at path:\n  " <> path)
  def exception({:invalid_args, args})    do
    [{"invalid args:"} | args]
    |> Enum.map_join("\n  ", &elem(&1, 0))
    |> put_message
  end
  def exception(:missing_swap_charset),    do: put_msg("please specify <new charset> to swap to")
  def exception(:extra_swap_charsets),     do: put_msg("may only swap one <charset> at a time")


  defp put_msg(msg), do: %__MODULE__{message: msg}
end
