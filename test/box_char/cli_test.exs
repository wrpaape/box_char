defmodule BoxChar.CLITest do
  use ExUnit.Case
  doctest BoxChar.CLI

  alias IO.ANSI
  alias BoxChar.CLI
  alias CLI.UsageError
  alias CLI.ArgVError

  import ExUnit.CaptureIO

  @usage  Application.get_env(:box_char, :usage)
  @usage_errors Application.get_env(:box_char, UsageError)
  @arg_v_errors Application.get_env(:box_char, ArgVError)
   |> Enum.map(fn({reason, msg_start})->
    {reason, Regex.compile!("^" <> msg_start <> ":")}
   end)

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
      |> Enum.random
      |> shuffle_in(rand_modes)
      |> shuffle_with(rand_charset_str)
      |> shuffle_with(safe_path)
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
      |> Enum.concat([safe_charset_str, safe_path])
      |> CLI.main
    end)
  end

  test "including invalid option(s) raises ArgVError ':unknown_options'" do
    assert_raise(ArgVError, arg_v_error_msg(:unknown_options), fn ->
      [~w(--ooga booga), ~w(--fluffy wuffy), ~w(--bing bang)]
      |> Enum.take_random(:rand.uniform(3))
      |> Enum.reduce(safe_arg_v, fn(inv_opt, arg_v)->
        Enum
        |> apply(Enum.random(~w(into concat)a), [inv_opt, arg_v])
      end)
      |> CLI.main
    end)
  end


  def rand_modes do
    @mode_flags 
    |> rand_chunk_vals
    |> Enum.map(&Enum.random/1)
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
    |> Keyword.values
    |> Enum.map_join("/", &Enum.random/1)
  end

  def safe_path, do: "./**"

  def take_rand_flags(flags, count) do
    flags
    |> Keyword.keys
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

  defp trim(str), do: :binary.replace(str, ansi_pattern, "", [:global]) 

  # defp pattern, do: :binary.compile_pattern([puts_status | ansi_pattern])

  # defp puts_status, do: capture_io(fn -> IO.puts "" end) 

  defp usage_error_msg(reason), do: Keyword.get(@usage_errors, reason)
  defp arg_v_error_msg(reason), do: Keyword.get(@arg_v_errors, reason)

  defp ansi_pattern do
    ANSI.__info__(:functions)
    |> Enum.filter_map(&(elem(&1, 1) == 0), &apply(ANSI, elem(&1, 0), []))
    |> Enum.filter(&is_binary/1)
    |> :binary.compile_pattern
  end
end
