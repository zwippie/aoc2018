defmodule Aoc2018.Day25 do

  def solve do
    read_input()
    |> build_constellations([])
    |> length
  end

  defp build_constellations([], constellations), do: constellations
  defp build_constellations(points, constellations) do
    [point | rest] = points
    constellation = add_points_to_constellation([point], rest)
    rest = points -- constellation
    build_constellations(rest, [constellation | constellations])
  end

  defp add_points_to_constellation(constellation, points) do
    pre_length = length(constellation)

    constellation = Enum.reduce(points, constellation, fn p, acc ->
      add_to_constellation_if_close_enough(acc, p)
    end)

    if length(constellation) == pre_length do
      constellation
    else
      points = points -- constellation
      add_points_to_constellation(constellation, points)
    end
  end

  defp add_to_constellation_if_close_enough(constellation, point) do
    constellation
    |> Enum.map(fn p -> distance(point, p) end)
    |> Enum.reject(fn d -> d > 3 end)
    |> Enum.any?
    |> case do
      true ->  [point | constellation]
      false -> constellation
    end
  end

  defp distance([a, b, c, d], [w, x, y, z]) do
    abs(w - a) + abs(x - b) + abs(y - c) + abs(z - d)
  end

  defp read_input do
    File.read!("priv/fixtures/day25.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
