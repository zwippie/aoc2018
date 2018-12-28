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

  # 76468059 too low
  def solve_b do
    input = read_input()
    # {{min_x, max_x}, {min_y, max_y}, {min_z, max_z}} = dimensions(input)
    # for x <- min_x..max_x, y <- min_y..max_y, z <- min_z..max_z do
    #   nodes_in_range(input, [x, y, z])
    # end
    {[x, y, z, r], count} =
      input
      |> Enum.map(fn pos -> {pos, nodes_in_range(input, pos)} end)
      |> Enum.max_by(fn {_, d} -> d end)
    distance({0, 0, 0}, {x, y, z})
  end

  defp dimensions(input) do
    {[min_x, _, _, _], [max_x, _, _, _]} = Enum.min_max_by(input, fn [x, _, _, _] -> x end)
    {[_, min_y, _, _], [_, max_y, _, _]} = Enum.min_max_by(input, fn [_, y, _, _] -> y end)
    {[_, _, min_z, _], [_, _, max_z, _]} = Enum.min_max_by(input, fn [_, _, z, _] -> z end)
    {{min_x, max_x}, {min_y, max_y}, {min_z, max_z}}
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

  defp nodes_in_range(input, [x, y, z]) do
    Enum.reduce(input, 0, fn [x2, y2, z2, r2], acc ->
      if distance({x, y, z}, {x2, y2, z2}) > r2 do
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
