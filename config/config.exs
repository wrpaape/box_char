defmodule MainConfig do
  def get do
    Keyword.new
    |> Keyword.put(:char_map, char_map)
    |> Keyword.put(:swap_map, swap_map)
  end

  defp char_map do
    light
    |> Enum.concat(heavy)
    |> Enum.concat(double)
  end

  defp swap_map do
    [light, heavy, double]
    |> Enum.map(fn(charset)->
      charset
      |> Enum.map(&elem(&1, 1))
    end)
    |> List.zip
    |> Enum.flat_map(fn({l, h, d})->
      [[:light,  :heavy,  l, h],
       [:light,  :double, l, d],
       [:heavy,  :light,  h, l],
       [:heavy,  :double, h, d],
       [:double, :light,  d, l],
       [:double, :heavy,  d, h],
       [:all,    :light,  h, l],
       [:all,    :light,  d, l],
       [:all,    :heavy,  l, h],
       [:all,    :heavy,  d, h],
       [:all,    :double, l, d],
       [:all,    :double, h, d]]
    end)
  end

  defp light do
    [{"q", "┌"}, {"w", "┬"}, {"e", "┐"},
     {"a", "├"}, {"s", "┼"}, {"d", "┤"},
     {"z", "└"}, {"x", "┴"}, {"c", "┘"},
     {"h", "─"}, {"v", "│"}]
  end

  defp heavy do
    [{"Q", "┏"}, {"W", "┳"}, {"E", "┓"},
     {"A", "┣"}, {"S", "╋"}, {"D", "┫"},
     {"Z", "┗"}, {"X", "┻"}, {"C", "┛"},
     {"H", "━"}, {"V", "┃"}]
  end

  defp double do
    [{"1", "╔"}, {"2", "╦"}, {"3", "╗"},
     {"4", "╠"}, {"5", "╬"}, {"6", "╣"},
     {"7", "╚"}, {"8", "╩"}, {"9", "╝"},
     {"=", "═"}, {"#", "║"}]
  end
end

defmodule CLIConfig do
  alias IO.ANSI
  alias Mix.Project
  alias BoxChar.CLI.UsageError
  alias BoxChar.CLI.InputError
  
  @spec_delim ","
  @usage ANSI.blue <> """
    usage:

      box_char map <escape_open>#{@spec_delim}<escape_close> <path>

    or

      box_char swap <old charset>#{@spec_delim}<new charset> <path>
    """ <> ANSI.reset

  def get do
    Keyword.new
    |> Keyword.put(:usage, @usage)
    |> Keyword.put(:spec_delim, @spec_delim)
    |> Keyword.put(:root_path, root_path)
    |> Keyword.put(:parse_opts, parse_opts)
    |> Keyword.put(:charset_flags, charset_flags)
    |> Keyword.put(UsageError, usage_errors)
    |> Keyword.put(InputError, input_errors)
  end

  defp root_path do
    ".."
    |> List.duplicate(4)
    |> Path.join
    |> Path.expand(Project.app_path)
  end

  defp parse_opts do
    [strict:  [help: :boolean, map: :string, swap: :string],
     aliases: [h:    :help,    m:   :map,    s:    :swap]]
  end

  defp charset_flags do
    [light:  ~w(light l),
     heavy:  ~w(heavy h),
     double: ~W(double d),
     all:    ~w(all a)]
  end

  defp usage_errors do
    [missing_mode:         "please specify <mode> of operation",
     multiple_modes:       "may only operate in one <mode> at a time",
     missing_path:         "please specify <path> to file or populated directory",
     extra_args:           "too many args!",
     no_delim_escapes:     "please delimit your <escapes> with '#{@spec_delim}'",
     no_delim_charsets:    "please delimit your <escapes> with '#{@spec_delim}'",
     delim_in_escapes:     "please exclude '#{@spec_delim}' from your <escapes>",
     missing_swap_charset: "please specify <new charset> to swap with",
     extra_swap_charsets:  "may only swap one <charset> at a time",
     same_swap_charsets:   "<new_charset> must be different than <old_charset>",
     swap_new_charset_all: "<old_charset> cannot be swapped for 'all' <charsets>"]
    |> Enum.map(fn({error, msg})->
      {error, msg <> "\n\n" <> @usage}
    end)
  end

  defp input_errors do
    [invalid_path:     "invalid path",
     unknown_options:  "unknown options",
     invalid_escapes:  "invalid <escapes>",
     invalid_charsets: "invalid <charsets>",
     invalid_charset:  "invalid charset selection",
     no_files_found:   "failed to find file(s) at path"]
  end
end


# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

  config :box_char, Keyword.merge(MainConfig.get, CLIConfig.get)

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :box_char, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:box_char, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
