defmodule Aoc2018.Day12 do
  # @count 20
  @count 100
  @bignum 50_000_000_000

  def solve do
    {input, rules} = read_input()
    output = apply_rules(input, rules, @count)
    no_filled = String.split(output, "") |> Enum.count(& &1 == "#") |> IO.inspect
    (@bignum - @count) * no_filled + score(output)
    # score(output)
  end

  defp apply_rules(input, _, 0) do
    IO.inspect {@count, input}
    input
  end
  defp apply_rules(input, rules, count) do
    # IO.inspect {@count - count, input}
    empty_input = List.duplicate(".", byte_size(input))
    rules
    |> Enum.reduce(empty_input, fn {pattern, replacement}, acc ->
      p = pattern |> String.replace(".", "\\.")
      regex = ~r/(?=#{p})/
      Regex.scan(regex, input, return: :index)
      |> List.flatten
      # |> IO.inspect(label: pattern)
      |> Enum.reduce(acc, fn {idx, _}, acc2 ->
        List.replace_at(acc2, idx + 2, replacement)
      end)
    end)
    |> Enum.join()
    |> apply_rules(rules, count - 1)
  end

  defp score(input, offset \\ -4) do
    input
    |> String.split("", trim: true)
    |> tl # remove first added pot
    |> Enum.with_index
    |> Enum.reduce(0, fn
      {".", _idx}, acc -> acc
      {"#", idx}, acc -> acc + idx + offset + 1
    end)
  end

  def read_input do
    [first_line | rules] =
      File.read!("priv/fixtures/day12.txt")
      |> String.split(~r/\n/, trim: true)

    [_, _, input] = String.split(first_line, " ")
    rules = Enum.map(rules, &parse_rule/1) |> Map.new()
    {"...." <> input <> String.duplicate(".", @count), rules}
  end

  defp parse_rule(rule) do
    String.split(rule, " => ") |> List.to_tuple
  end
end
