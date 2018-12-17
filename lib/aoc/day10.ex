defmodule Aoc2018.Day10 do
  @line_regex ~r/position=<(.*\d+),(.*\d+)> velocity=<(.*\d+),(.*\d+)>/

  def solve do
    {counter, stars} = read_input() |> move_stars
    print_stars(stars)
    IO.puts "After #{counter} steps"
  end

  defp move_stars(input), do: move_stars(input, 0, size_of(input))
  defp move_stars(input, counter, last_size) do
    new_input = Enum.map(input, fn [x, y, dx, dy] -> [x + dx, y + dy, dx, dy] end)
    new_size = size_of(new_input)
    if new_size > last_size do
      {counter, input}
    else
      move_stars(new_input, counter + 1, new_size)
    end
  end

  defp size_of(input) do
    {w, h} = dimensions(input)
    w * h
  end

  defp dimensions(input) do
    {[min_x, _, _, _], [max_x, _, _, _]} = Enum.min_max_by(input, fn [x, _, _, _] -> x end)
    {[_, min_y, _, _], [_, max_y, _, _]} = Enum.min_max_by(input, fn [_, y, _, _] -> y end)
    {max_x - min_x + 1, max_y - min_y + 1}
  end

  defp print_stars(input) do
    {w, _h} = dimensions(input)

    star_coords =
      input
      |> Enum.map(fn [x, y, _, _] -> {x, y} end)
      |> Map.new(fn k -> {k, "#"} end)

    input
    |> grid_coordinates()
    |> Enum.reduce([], fn coord, acc -> [Map.get(star_coords, coord, " ") | acc] end)
    |> Enum.reverse
    |> Enum.chunk_every(w)
    |> Enum.map(&Enum.join/1)
    |> Enum.each(&IO.puts/1)
  end

  def grid_coordinates(input) do
    {[min_x, _, _, _], [max_x, _, _, _]} = Enum.min_max_by(input, fn [x, _, _, _] -> x end)
    {[_, min_y, _, _], [_, max_y, _, _]} = Enum.min_max_by(input, fn [_, y, _, _] -> y end)
    for y <- min_y..max_y, x <- min_x..max_x, do: {x, y}
  end

  defp read_input do
    File.read!("priv/fixtures/day10.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&to_vector/1)
  end

  defp to_vector(line) do
    [vector] = Regex.scan(@line_regex, line, capture: :all_but_first)
    Enum.map(vector, fn v -> String.trim(v) |> String.to_integer end)
  end
end
