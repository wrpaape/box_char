# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

alias BoxChar.ArgVError
alias BoxChar.CLIError

  config :box_char, [def_path: "**",
                     def_opts: ~w(map heavy)a,
                     timeout:  :infinity,
                     errors: [{CLIError,  [invalid_path:         "invalid path",
                                           no_files_found:       "failed to find file(s) at path",
                                           invalid_charset:      "invalid charset"]},
                              {ArgVError, [missing_mode:         "please specify <mode> of operation",
                                           multiple_modes:       "may only operate in one <mode> at a time",
                                           missing_path:         "please specify <path> to file or populated directory",
                                           extra_args:           "too many args!",
                                           missing_swap_charset: "please specify <new charset> to swap with",
                                           extra_swap_charsets:  "may only swap one <charset> at a time",
                                           same_swap_charsets:   "<new_charset> must be different than <old_charset>",
                                           swap_new_charset_all: "<old_charset> cannot be swapped for all charsets"]}],
                     usage:    """

                               usage:

                                 box_char <path> map <charset>

                               or

                                 box_char <path> map <charsets (slash delimited)>

                               or

                                 box_char <path> swap <old charset>/<new charset>
                               """]  

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
