# See https://gitlab.com/NobbZ/aoc_ex/blob/master/lib/y2018/d3.ex
# This map based approach is soo much faster than my list based attempt...
defmodule Aoc2018.Day3again do
  @line_regex ~r/\#(\d+) \@ (\d+),(\d+)\: (\d+)x(\d+)/

  def solve do
    read_input()
    |> Enum.map(&parse_input_line/1)
    |> make_claims()
  end

  def make_claims(input) do
    input
    |> claims_per_square_inch()
    |> Enum.count(fn {_, n} -> n >= 2 end)
  end

  defp claims_per_square_inch(input) do
    Enum.reduce(input, %{}, fn %{coord: coord, size: size}, acc ->
      claims(coord, size)
      |> Enum.reduce(acc, fn pos, acc -> Map.update(acc, pos, 1, &(&1 + 1)) end)
    end)
  end

  defp claims({x, y}, {width, height}) do
    for x <- x..(x + width - 1), y <- y..(y + height - 1), do: {x, y}
  end

  defp parse_input_line(line) do
    [parsed_line] = Regex.scan(@line_regex, line, capture: :all_but_first)
    [id, left, top, width, height] = Enum.map(parsed_line, &String.to_integer/1)
    %{id: id, coord: {left, top}, size: {width, height}}
  end

  defp read_input do
    File.read!("priv/fixtures/day3.txt")
    |> String.split(~r/\n/, trim: true)
  end
end

defmodule Aoc2018.Day3b do
  @line_regex ~r/\#(\d+) \@ (\d+),(\d+)\: (\d+)x(\d+)/

  def solve do
    read_input()
    |> Enum.map(&parse_input_line/1)
    |> find_single_claim()
  end

  def find_single_claim(input) do
    claim_map = claims_per_square_inch(input)

    Enum.find(input, fn %{coord: coord, size: size} ->
      claims(coord, size)
      |> Enum.all?(fn pos -> claim_map[pos] == 1 end)
    end)
    |> (& &1[:id]).()

  end

  defp claims_per_square_inch(input) do
    Enum.reduce(input, %{}, fn %{coord: coord, size: size}, acc ->
      claims(coord, size)
      |> Enum.reduce(acc, fn pos, acc -> Map.update(acc, pos, 1, &(&1 + 1)) end)
    end)
  end

  defp claims({x, y}, {width, height}) do
    for x <- x..(x + width - 1), y <- y..(y + height - 1), do: {x, y}
  end


  defp parse_input_line(line) do
    [parsed_line] = Regex.scan(@line_regex, line, capture: :all_but_first)
    [id, left, top, width, height] = Enum.map(parsed_line, &String.to_integer/1)
    %{id: id, coord: {left, top}, size: {width, height}}
  end

  defp read_input do
    File.read!("priv/fixtures/day3.txt")
    |> String.split(~r/\n/, trim: true)
  end
end
