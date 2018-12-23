defmodule Aoc2018.Day18 do
  def solve do
    map =
      read_input()
      |> next_generation(10)
      |> print_map(0)

    type_count(map, :tree) * type_count(map, :lumber)
  end

  # not 183040 too low?
  # not 195160 too high
  # not 194449 too high
  # not 180942
  # not 189912
  # try 183787
  def solve_b do
    {map, generation, history} =
      read_input()
      |> find_duplicate_generation(0, [read_input()])

    history = Enum.reverse(history)
    first_occurence = Enum.find_index(history, fn hist -> hist == map end)

    print_map(Enum.at(history, first_occurence), first_occurence)
    print_map(map, generation)

    IO.inspect(generation - first_occurence, label: "period length")
    offset = rem(1_000_000_000 - first_occurence, generation - first_occurence + 1) + first_occurence

    map = Enum.at(history, offset) |> print_map(offset)

    type_count(map, :tree) * type_count(map, :lumber)
  end

  defp find_duplicate_generation(map, generation \\ 0, history \\ [])
  defp find_duplicate_generation(map, generation, history) do
    map = next_generation(map, 1)
    cond do
      map in history -> {map, generation, history}
      true -> find_duplicate_generation(map, generation + 1, [map | history])
    end
  end

  defp next_generation(map, 0), do: map
  defp next_generation(map, generation) do
    map
    # |> print_map(generation)
    |> Map.keys
    |> Enum.reduce(%{}, fn pos, acc -> update_cell(map, pos, acc) end)
    |> next_generation(generation - 1)
  end

  defp update_cell(map, pos, acc) do
    case Map.get(map, pos) do
      :open   -> update_open_cell(map, pos, acc)
      :tree   -> update_tree_cell(map, pos, acc)
      :lumber -> update_lumber_cell(map, pos, acc)
    end
  end

  defp update_open_cell(map, pos, acc) do
    if type_count(map, pos, :tree) > 2 do
      Map.put(acc, pos, :tree)
    else
      Map.put(acc, pos, :open)
    end
  end

  defp update_tree_cell(map, pos, acc) do
    if type_count(map, pos, :lumber) > 2 do
      Map.put(acc, pos, :lumber)
    else
      Map.put(acc, pos, :tree)
    end
  end

  defp update_lumber_cell(map, pos, acc) do
    if type_count(map, pos, :tree) > 0 && type_count(map, pos, :lumber) > 0 do
      Map.put(acc, pos, :lumber)
    else
      Map.put(acc, pos, :open)
    end
  end

  defp type_count(map, cell_type) do
    Enum.count(map, fn {_, type} -> type == cell_type end)
  end

  defp type_count(map, pos, cell_type) do
    map
    |> surrounding_cells(pos)
    |> Enum.count(fn type -> type == cell_type end)
  end

  defp surrounding_cells(map, pos) do
    pos
    |> surrounding_coords
    |> Enum.map(fn pos -> Map.get(map, pos) end)
  end

  defp surrounding_coords({row, col}) do
    [
      {row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
      {row,     col - 1},                 {row,     col + 1},
      {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}
    ]
  end

  defp print_map(map, generation) do
    {{{min_x, _}, _}, {{max_x, _}, _}} =
      Enum.min_max_by(map, fn {{x, _y}, _} -> x end)
    {{{_, min_y}, _}, {{_, max_y}, _}} =
      Enum.min_max_by(map, fn {{_x, y}, _} -> y end)

    output = type_count(map, :tree) * type_count(map, :lumber)
    IO.puts("generation #{generation}, output #{output}")
    for x <- min_x..max_x do
      for y <- min_y..max_y do
        case Map.get(map, {x, y}) do
          :open   -> "."
          :tree   -> "|"
          :lumber -> "#"
        end
      end
      |> Enum.join()
      |> IO.puts
    end

    map
  end

  defp read_input do
    File.read!("priv/fixtures/day18.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.with_index
    |> Enum.reduce(%{}, &parse_line/2)
  end

  defp parse_line({line, row_idx}, acc) do
    line
    |> String.split("", trim: true)
    |> Enum.with_index
    |> Enum.reduce(acc, fn {cell, col_idx}, acc2 -> parse_cell(cell, row_idx, col_idx, acc2) end)
  end

  defp parse_cell(cell, row_idx, col_idx, acc) do
    case cell do
      "." -> Map.put(acc, {row_idx, col_idx}, :open)
      "|" -> Map.put(acc, {row_idx, col_idx}, :tree)
      "#" -> Map.put(acc, {row_idx, col_idx}, :lumber)
    end
  end
end

defmodule Aoc2018.Day18b do
  def solve do
    Aoc2018.Day18.solve_b()
  end
end
