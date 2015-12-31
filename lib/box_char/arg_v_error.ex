defmodule BoxChar.ArgVError do
  use GenError
  error :missing_mode, "please specify <mode> of operation")
  error :multiple_modes, "may only operate in one <mode> at a time")
  error :missing_path,  "please specify <path> to file or populated directory")
  error :extra_args,  "too many args!")
end
