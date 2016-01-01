defmodule BoxChar.ArgVError do
  use GenError

  error missing_mode:,         "please specify <mode> of operation"
  error multiple_modes:,       "may only operate in one <mode> at a time"
  error missing_path:,         "please specify <path> to file or populated directory"
  error extra_args:,           "too many args!"
  error missing_swap_charset:, "please specify <new charset> to swap with"
  error extra_swap_charsets:,  "may only swap one <charset> at a time"
  error same_swap_charsets:,   "<new_charset> must be different than <old_charset>"
  error swap_new_charset_all:, "<old_charset> cannot be swapped for all charsets"
end
