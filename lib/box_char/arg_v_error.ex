defmodule BoxChar.ArgVError do
  use GenError

  error :missing_mode
  error :multiple_modes
  error :missing_path
  error :extra_args
  error :missing_swap_charset
  error :extra_swap_charsets
  error :same_swap_charsets
  error :swap_new_charset_all
end
