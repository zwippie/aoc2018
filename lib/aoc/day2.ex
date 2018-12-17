defmodule Aoc2018.Day2a do
  def solve do
    read_input()
    |> Enum.map(&split_chars/1)
    |> Enum.map(&group_chars/1)
    |> Enum.map(&count_chars/1)
    |> Enum.map(&count_two_three/1)
    |> Enum.reduce({0, 0}, &sum_two_three/2)
    |> mul_two_three()
  end

  defp split_chars(values) do
    String.split(values, "", trim: true)
  end

  defp group_chars(values) do
    Enum.group_by(values, &(&1), &(&1))
  end

  defp count_chars(values) do
    Enum.map(values, fn {_k, v} -> length(v) end)
  end

  defp count_two_three(values) do
    count_2 = Enum.count(values, &(&1 == 2))
    count_3 = Enum.count(values, &(&1 == 3))
    case {count_2, count_3} do
      {0, 0} -> {0, 0}
      {_, 0} -> {1, 0}
      {0, _} -> {0, 1}
      {_, _} -> {1, 1}
    end
  end

  defp sum_two_three({a, b}, {x, y}), do: {x + a, y + b}

  defp mul_two_three({a, b}), do: a * b

  defp read_input do
    File.read!("priv/fixtures/day2.txt")
    |> String.split(~r/\n/, trim: true)
  end
end

defmodule Aoc2018.Day2b do
  def solve do
    read_input()
    |> Enum.map(&split_chars/1)
    |> find_single_diff([])
    |> hd()
    |> shared_chars()
    |> Enum.reverse()
    |> Enum.join()
  end

  defp shared_chars({chars_a, chars_b}) do
    Enum.zip(chars_a, chars_b)
    |> Enum.reduce([], fn {char_a, char_b}, acc ->
      if char_a == char_b, do: [char_a | acc], else: acc
    end)
  end

  defp find_single_diff([], acc), do: acc
  defp find_single_diff([head | tail], acc) do
    for str <- tail do
      case char_diff_count(head, str) do
        1 -> {head, str}
        _ -> nil
      end
    end
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> find_single_diff(tail, acc)
      value -> find_single_diff(tail, value)
    end
  end

  defp char_diff_count(chars_a, chars_b) do
    Enum.zip(chars_a, chars_b)
    |> Enum.reduce(0, fn {char_a, char_b}, acc ->
      if char_a != char_b, do: acc + 1, else: acc
    end)
  end

  defp split_chars(values) do
    String.split(values, "", trim: true)
  end

  defp read_input do
    File.read!("priv/fixtures/day2.txt")
    |> String.split(~r/\n/, trim: true)
  end
end
