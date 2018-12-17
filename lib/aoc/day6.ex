defmodule Aoc2018.Day6 do
  @coord_regex ~r/(\d+), (\d+)/

  def solve do
    input = read_input()
    {max_x, max_y} = find_max(input)

    distances =
      for x <- 0..max_x,
          y <- 0..max_y,
          {x, y} not in input do
        # all distances from each coord to this point
        distances =
          input
          |> Enum.with_index
          |> Enum.map(&manhattan_distance({x, y}, &1))

        min_distance = Enum.min_by(distances, &(elem(&1, 1)))
        if is_duplicate_distance(distances, elem(min_distance, 1)) > 1 do
          {{x, y}, nil}
        else
          {{x, y}, min_distance}
        end
      end
      |> Enum.reject(fn {_, dist} -> is_nil(dist) end)

    # write_output(distances)

    # find all point indices of points on the borders
    border_idxs =
      distances
      |> Enum.filter(fn {{x, y}, _dist} ->
        x == 0 || y == 0 || x == max_x || y == max_y
      end)
      |> Enum.map(fn {_, {idx, _dist}} -> idx end)
      |> Enum.uniq

    distances
    |> Enum.reject(fn {_, {idx, _dist}} -> idx in border_idxs end)
    |> Enum.reduce(%{}, fn {_, {idx, _dist}}, acc ->
      Map.update(acc, idx, 2, &(&1 + 1))
    end)
    |> Map.values
    |> Enum.max
  end

  def solve_b do
    input = read_input()
    {max_x, max_y} = find_max(input)

    for x <- 0..max_x,
        y <- 0..max_y do
      # all distances from each coord to this point
      input
      |> Enum.map(&manhattan_distance2({x, y}, &1))
      |> Enum.sum
      # |> IO.inspect
    end
    |> Enum.filter(&(&1 < 10_000))
    |> length
  end

  defp is_duplicate_distance(distances, distance) do
    Enum.count(distances, fn {_idx, dist} -> dist == distance end)
  end

  defp manhattan_distance({x1, y1}, {{x2, y2}, idx}) do
    {idx, abs(x2 - x1) + abs(y2 - y1)}
  end

  defp manhattan_distance2({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  defp find_max(coords, acc \\ {0, 0})
  defp find_max([], acc), do: acc
  defp find_max([{x, y} | tail], {max_x, max_y}) do
    find_max(tail, {max(x, max_x), max(y, max_y)})
  end

  defp read_input do
    File.read!("priv/fixtures/day6.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&to_coords/1)
  end

  defp to_coords(line) do
    [[x, y]] = Regex.scan(@coord_regex, line, capture: :all_but_first)
    {String.to_integer(x), String.to_integer(y)}
  end
end

defmodule Aoc2018.Day6b do
  def solve do
    Aoc2018.Day6.solve_b
  end
end
