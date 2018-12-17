defmodule Aoc2018.Day1a do
  # 416
  def solve do
    read_input()
    |> Enum.sum()
  end

  defp read_input do
    File.read!("priv/fixtures/day1a.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Aoc2018.Day1b do
  def solve do
    read_input()
    |> Stream.cycle()
    |> Enum.reduce_while({0, []}, &sum_and_check/2)
  end

  def sum_and_check(x, {sum, memory}) do
    sum = sum + x
    cond do
      sum in memory -> {:halt, sum}
      true -> {:cont, {sum, [sum | memory]}}
    end
  end

  defp read_input do
    File.read!("priv/fixtures/day1a.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Aoc2018.Day1bOld do
  # 56752
  def solve do
    input = read_input()
    find_recurring_frequence(input, input, [], 0)
  end

  def find_recurring_frequence(input, [], memory, acc) do
    IO.inspect {"cycle", length(memory)}
    find_recurring_frequence(input, input, memory, acc)
  end
  def find_recurring_frequence(input, [head | tail], memory, acc) do
    sum = acc + head
    cond do
      sum in memory -> sum
      true -> find_recurring_frequence(input, tail, [sum | memory], sum)
    end
  end

  defp read_input do
    File.read!("priv/fixtures/day1a.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
