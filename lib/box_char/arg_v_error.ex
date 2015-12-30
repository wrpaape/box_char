defmodule BoxChar.ArgVError do
  def exception(:missing_mode),           do: put_msg("please specify <mode> of operation")
  def exception(:multiple_modes),         do: put_msg("may only operate in one <mode> at a time")
  def exception(:missing_path),           do: put_msg("please specify <path> to file or populated directory")
  def exception(:extra_args),             do: put_msg("too many args!")
  
  defp put_msg(msg), do: %__MODULE__{message: msg}
end
