defmodule BoxChar.CLITest do
  use ExUnit.Case
  doctest BoxChar.CLI

  alias IO.ANSI
  alias BoxChar.CLI
  alias CLI.UsageError
  alias CLI.ArgVError

  import ExUnit.CaptureIO

  @usage         Application.get_env(:box_char, :usage)
  @root_path     Application.get_env(:box_char, :root_path)
  @usage_errors  Application.get_env(:box_char, UsageError)
  @arg_v_errors  Application.get_env(:box_char, ArgVError)
    |> Enum.map(fn({reason, msg_start})->
      {reason, Regex.compile!("^" <> Regex.escape(msg_start) <> ":\n  .*$", "s")}
    end)

  @dummy_path    ~w(test box_char dummy_files)
    |> Path.join
    |> Path.expand(@root_path)

  @charset_flags Application.get_env(:box_char, :charset_flags) 
  @help_flags    ~w(--help -h)
  @mode_flags    [map: ~w(--map -m), swap: ~w(--swap -s)]

  test "assert_raise" do
    assert_raise ArithmeticError, "bad argument in arithmetic expression", fn ->
      1 + "test"
    end
  end

  test "help flag in argv => prints usage" do
    assert capture_io(fn ->
      @help_flags
      |> Enum.take_random(1)
      |> CLI.main
    end) == @usage
  end

  test "forgetting <mode> raises UsageError ':missing_mode'" do
    assert_raise(UsageError, usage_error_msg(:missing_mode), fn ->
      [rand_charset_str, safe_path] 
      |> CLI.main
    end)
  end

  test "including more than one <mode> raises UsageError ':multiple_modes'" do
    assert_raise(UsageError, usage_error_msg(:multiple_modes), fn ->
      @mode_flags
      |> take_rand_flags(2)
      |> Enum.flat_map(&[&1, safe_charset_str])
      |> List.insert_at(-1, safe_path)
      |> CLI.main
    end)
  end

  test "including invalid option(s) raises ArgVError ':unknown_options'" do
    assert_raise(ArgVError, arg_v_error_msg(:unknown_options), fn ->
      [~w(--ooga booga), ~w(--fluffy wuffy), ~w(--bing bang)]
      |> take_at_least(1)
      |> rand_into_or_concat(safe_arg_v)
      |> CLI.main
    end)
  end

  test "forgetting <path> raises UsageError ':missing_path'" do
    assert_raise(UsageError, usage_error_msg(:missing_path), fn ->
      safe_mode_charset
      |> CLI.main
    end)
  end

  test "including additional args raises UsageError ':extra_args'" do
    assert_raise(UsageError, usage_error_msg(:extra_args), fn ->
      [["foo"], ["bar"], ["baz"]]
      |> take_at_least(1)
      |> rand_into_or_concat(safe_arg_v)
      |> CLI.main
    end)
  end

  test "nonexistent <path> raises ArgVError ':invalid_path'" do
    assert_raise(ArgVError, arg_v_error_msg(:invalid_path), fn ->
      safe_mode_charset
      |> List.insert_at(-1, path_to_nothing)
      |> CLI.main
    end)
  end

  test "valid <path> with no files raises ArgVError ':no_files_found'" do
    assert_raise(ArgVError, arg_v_error_msg(:no_files_found), fn ->
      safe_mode_charset
      |> List.insert_at(-1, empty_path)
      |> CLI.main
    end)
  end

  test "specifying a single <charset> in 'swap' <mode> raises UsageError ':missing_swap_charset'" do
    assert_raise(UsageError, usage_error_msg(:missing_swap_charset), fn ->
      rand_swap_flag
      |> Enum.concat(take_rand_flags(@charset_flags, 1))
      |> List.insert_at(-1, safe_path)
      |> CLI.main
    end)
  end

  test "duplicate <charsets> (<charset>/<charset>) in 'swap' <mode> raises UsageError ':same_swap_charsets'" do
    assert_raise(UsageError, usage_error_msg(:same_swap_charsets), fn ->
      @charset_flags
      |> Keyword.delete(:all)
      |> take_rand_flags(1)
      |> Enum.map(&Path.join(&1, &1))
      |> Enum.into(rand_swap_flag)
      |> List.insert_at(-1, safe_path)
      |> CLI.main
    end)
  end

  test "specifying 'all' as <new_charset> in 'swap' <mode> raises UsageError ':swap_new_charset_all'" do
    assert_raise(UsageError, usage_error_msg(:swap_new_charset_all), fn ->
      @charset_flags
      |> Keyword.get(:all)
      |> Enum.take_random(1)
      |> Enum.into(take_rand_flags(@charset_flags, 1))
      |> charset_str_list
      |> List.insert_at(-1, safe_path)
      |> Enum.into(rand_swap_flag)
      |> CLI.main
    end)
  end

  test "specifying 3 or more modes in 'swap' <mode> raises UsageError ':extra_swap_charsets'" do
    assert_raise(UsageError, usage_error_msg(:extra_swap_charsets), fn ->
      @charset_flags
      |> take_at_least(3)
      |> map_rand_flags
      |> charset_str_list
      |> List.insert_at(-1, safe_path)
      |> Enum.into(rand_swap_flag)
      |> CLI.main
    end)
  end

  def charset_str_list(flags), do: [Path.join(flags)]

  def rand_swap_flag do
    @mode_flags
    |> Keyword.get(:swap)
    |> Enum.take_random(1)
  end

  def safe_mode_charset do
    @mode_flags
    |> take_rand_flags(1)
    |> List.insert_at(-1, safe_charset_str)
  end

  def take_rand_flags(flags, count) do
    flags
    |> Enum.take_random(count)
    |> map_rand_flags
  end

  def map_rand_flags(flags) do
    flags
    |> Enum.map(fn({_k, list})->
      list
      |> Enum.random
    end)
  end

  def rand_charset_str do
    @charset_flags
    |> rand_chunk_vals
    |> Enum.map_join("/", &Enum.random/1) 
  end

  def safe_arg_v, do: take_rand_flags(@mode_flags, 1) ++ [safe_charset_str, safe_path]

  def safe_charset_str do
    @charset_flags
    |> Keyword.delete_first(:all)
    |> Enum.take_random(2)
    |> map_rand_flags
    |> Path.join
  end

  def safe_path,      do: Path.join(@dummy_path, "**")
  def empty_path,     do: Path.join(@dummy_path, "empty_dir")
  def path_to_nothing do
    ~w(path to nothing)
    |> Path.join
    |> Path.expand(@dummy_path)
  end

  def rand_into_or_concat(args, initial_argv) do
    args
    |> Enum.reduce(initial_argv, fn(arg, arg_v)->
      Enum
      |> apply(Enum.random(~w(into concat)a), [arg, arg_v])
    end)
  end

  def take_at_least(list, min) do
    list
    |> Enum.take_random(Enum.random(min..length(list)))
  end
  
  def take_rand_flags(flags, count) do
    flags
    |> Keyword.values
    |> List.flatten
    |> Enum.take_random(count)
  end

  def shuffle_in(term, list),   do: Enum.shuffle([term | list])
  def shuffle_with(list, term), do: Enum.shuffle([term | list])
  def shuffle_into(l1, l2),     do: Enum.shuffle(l1 ++ l2)

  def rand_chunk(list), do: Enum.take_random(list, rand_count(list))
  def rand_count(list), do: :rand.uniform(length(list) + 1) - 1
  def rand_chunk_vals(flags) do
    flags
    |> rand_chunk
    |> Keyword.values
  end

  defp usage_error_msg(reason), do: Keyword.get(@usage_errors, reason)
  defp arg_v_error_msg(reason), do: Keyword.get(@arg_v_errors, reason)
end
