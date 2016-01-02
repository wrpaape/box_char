defmodule BoxChar.CLI.UsageError do
  use GenError

  @errors Application.get_env(:box_char, __MODULE__)

  error :missing_mode,         get_msg(:missing_mode)
  error :multiple_modes,       get_msg(:multiple_modes)
  error :missing_path,         get_msg(:missing_path)
  error :missing_delim,        get_msg(:missing_delim)
  error :extra_args,           get_msg(:extra_args)
  error :missing_swap_charset, get_msg(:missing_swap_charset)
  error :extra_swap_charsets,  get_msg(:extra_swap_charsets)
  error :same_swap_charsets,   get_msg(:same_swap_charsets)
  error :swap_new_charset_all, get_msg(:swap_new_charset_all)
  error :delim_in_escapes,     get_msg(:delim_in_escapes)

  error_with_arg :invalid_escapes,   get_msg(:invalid_escapes)
  error_with_arg :invalid_charsets,  get_msg(:invalid_charsets)
  error_with_arg :no_delim_escapes,  get_msg(:no_delim_escapes)
  error_with_arg :no_delim_charsets, get_msg(:no_delim_charsets)

  defp get_msg(error), do: Keyword.get(@errors, error)
end
