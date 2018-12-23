defmodule Aoc2018.Day5a do
  def solve do
    read_input()
    |> to_charlist
    |> remove_next_pair([])
    |> length
  end

  defp remove_next_pair(input, acc) when length(input) < 2, do: input ++ acc
  defp remove_next_pair([a, b | rest], acc) do
    if abs(a - b) == 32 do
      {f, acc} = Enum.split(acc, 1)
      remove_next_pair(f ++ rest, acc)
    else
      remove_next_pair([b | rest], [a | acc])
    end
  end

  defp read_input do
    File.read!("priv/fixtures/day5.txt")
    |> String.split(~r/\n/, trim: true)
    |> hd
  end
end

defmodule Aoc2018.Day5b do
  def solve do
    input = read_input() |> to_charlist
    ?A..?Z
    |> Stream.map(&(remove_chars(input, &1)))
    |> Stream.map(&remove_next_pair/1)
    |> Enum.min_by(&length/1)
    |> length
  end

  defp remove_chars(input, char) do
    IO.inspect("remove #{char}")
    Enum.reject(input, fn c -> char == c || char + 32 == c end)
  end

  defp remove_next_pair(input, acc \\ [])
  defp remove_next_pair(input, acc) when length(input) < 2, do: input ++ acc
  defp remove_next_pair([a, b | rest], acc) do
    if abs(a - b) == 32 do
      {f, acc} = Enum.split(acc, 1)
      remove_next_pair(f ++ rest, acc)
    else
      remove_next_pair([b | rest], [a | acc])
    end
  end

  defp read_input do
    File.read!("priv/fixtures/day5.txt")
    |> String.split(~r/\n/, trim: true)
    |> hd
  end
end
