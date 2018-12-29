defmodule Aoc2018.Day23 do
  @line_regex ~r/pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)/

  def solve do
    input = read_input()
    [x, y, z, r] = find_strongest(input)
    Enum.reduce(input, 0, fn [x2, y2, z2, _r2], acc ->
      if distance({x, y, z}, {x2, y2, z2}) > r do
        acc
      else
        acc + 1
      end
    end)
  end

  def solve_b do
    input = read_input()
    {[x, y, z, _r], _count} =
      input
      |> Enum.map(fn pos -> {pos, nodes_in_range(input, pos)} end)
      |> Enum.max_by(fn {_, d} -> d end)
    distance({0, 0, 0}, {x, y, z})
  end

  defp nodes_in_range(input, [x, y, z, r]) do
    Enum.reduce(input, 0, fn [x2, y2, z2, _], acc ->
      if distance({x, y, z}, {x2, y2, z2}) > r do
        acc
      else
        acc + 1
      end
    end)
  end

  defp find_strongest(input) do
    Enum.max_by(input, fn [_, _, _, d] -> d end)
  end

  defp distance({a, b, c}, {d, e, f}) do
    abs(d - a) + abs(e - b) + abs(f - c)
  end

  defp read_input do
    File.read!("priv/fixtures/day23.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    Regex.scan(@line_regex, line, capture: :all_but_first)
    |> Enum.map(&to_integers/1)
    |> hd
  end

  defp to_integers(list) do
    Enum.map(list, &String.to_integer/1)
  end
end

defmodule Aoc2018.Day23b do
  def solve do
    Aoc2018.Day23.solve_b()
  end
end
