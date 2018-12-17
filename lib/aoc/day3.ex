defmodule Aoc2018.Day3a do
  @line_regex ~r/\#(\d+) \@ (\d+),(\d+)\: (\d+)x(\d+)/
  @fabric_side 998

  def solve do
    read_input()
    |> Enum.map(&parse_input_line/1)
    # |> Enum.reduce({0, 0}, &determine_dimensions/2)
    # |> Enum.map(&create_area/1)
    |> Enum.reduce(empty_fabric(), &claim_area/2)
    |> Matrex.to_list
    |> Enum.reduce(0, fn x, acc -> if x > 1, do: acc + 1, else: acc end)
  end

  defp determine_dimensions(%{left: left, top: top, width: width, height: height}, {h, w}) do
    {max(h, top + height), max(w, left + width)}
  end

  defp create_area(area) do
    IO.inspect area.id
    cols = area.left..(area.left + area.width - 1)
    rows = area.top..(area.top + area.height - 1)
    cells = for row_id <- rows, col_id <- cols, do: {row_id, col_id}
    set_cells(cells, empty_fabric())
  end

  defp set_cells([], acc), do: acc
  defp set_cells([{row_id, col_id} | tail], acc) do
    set_cells(tail, Matrex.set(acc, row_id + 1, col_id + 1, 1))
  end

  defp claim_area(area, acc) do
    IO.inspect(area, label: "claim_area")
    cols = area.left..(area.left + area.width - 1)
    rows = area.top..(area.top + area.height - 1)
    cells = for row_id <- rows, col_id <- cols, do: {row_id, col_id}
    # cells = for row_id <- rows, col_id <- cols, do: (row_id * @fabric_side) + col_id
    increment_cells(cells, acc)
  end

  defp increment_cells([], acc), do: acc
  defp increment_cells([{row_id, col_id} | tail], acc) do
    increment_cells(tail, Matrex.update(acc, row_id + 1, col_id + 1, &(&1 + 1)))
    # increment_cells(tail, List.update_at(acc, head, &(&1 + 1)))
  end

  defp empty_fabric do
    # List.duplicate(0, @fabric_side * @fabric_side)
    Matrex.zeros(@fabric_side, @fabric_side)
  end

  defp parse_input_line(line) do
    [parsed_line] = Regex.scan(@line_regex, line, capture: :all_but_first)
    [id, left, top, width, height] = Enum.map(parsed_line, &String.to_integer/1)
    %{id: id, left: left, top: top, width: width, height: height}
  end

  defp read_input do
    File.read!("priv/fixtures/day3.txt")
    |> String.split(~r/\n/, trim: true)
  end
end
