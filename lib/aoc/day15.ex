defmodule Aoc2018.Day15 do
  # char codes
  @wall 35
  @open 46
  @elf  69
  @goblin 71

  @damage 3
  @hitpoints 200

  def solve do
    {map, units} = read_input()
    next_round(map, units, 1)
  end

  defp next_round(map, units, round_count) do
    units = units |> reset_units_for_round |> sort_units
    unit_positions = Enum.map(units, fn unit -> {unit.row, unit.col} end)

    {map, units} =
      unit_positions
      |> Enum.reduce({map, units}, &turn_unit/2)

    # {map, units} =
    #   units
    #   |> reset_units_for_round
    #   |> sort_units
    #   # |> turn_units({map, []})
    #   |> Enum.reduce({map, units, 0}, &turn_unit/2)

    cond do
      length(units) == 1 -> {round_count, map, units}
      round_count == 2 -> {round_count, map, units}
      true ->
        next_round(map, units, round_count + 1)
    end
  end

  # defp turn_units([], acc) when length(acc) == 1, do: {:halt, acc}
  # defp turn_units([], acc), do: {:cont, acc}
  # defp turn_units([unit | units], {map, units_done}) do
  #   turn_units(units, turn_unit(unit, {map, units_done}))
  # end

  defp turn_unit({row, col}, {map, units}) do
    unit_idx = Enum.find_index(units, fn u -> u.row == row && u.col == col end)
    unit = Enum.at(units, unit_idx) |> IO.inspect

    targets = find_targets(map, units, unit) |> IO.inspect


    unit = %{unit | done: true}
    units = List.update_at(units, unit_idx, fn _ -> unit end)

    {map, units}
  end

  defp find_targets(map, units, unit) do
    distances =
      units
      # get distances
      |> Enum.reduce([], fn unit_b, acc ->
        cond do
          unit == unit_b -> acc
          true -> [adjacent_places(map, unit_b) | acc]
        end
      end)
      # |> Enum
  end

  defp sort_units(units) do
    Enum.sort_by(units, fn %{row: row, col: col} -> row * 100 + col end)
  end

  defp reset_units_for_round(units) do
    Enum.map(units, fn unit -> %{unit | done: false} end)
  end

  defp distance(%{row: row_a, col: col_a}, %{row: row_b, col: col_b}) do
    abs(row_b - row_a) + abs(col_b - col_a)
  end

  defp adjacent_places(map, unit) do
    [
      {unit.row - 1, unit.col},
      {unit.row + 1, unit.col},
      {unit.row, unit.col - 1},
      {unit.row, unit.col + 1}
    ]
    |> Enum.reduce([], fn {row, col} = spot, acc ->
      case Map.get(map, {row, col}) do
        ?.  -> [{{row, col}, {unit.row, unit.col}} | acc]
        _   -> acc
      end
    end)
    |> List.flatten
  end

  # Handle input

  defp read_input do
    input =
      File.read!("priv/fixtures/day15example1.txt")
      |> String.split(~r/\n/, trim: true)
      |> Enum.with_index

    {build_map(input, %{}), find_units(input, {[], 0})}
  end

  defp build_map([], acc), do: acc
  defp build_map([{line, row_idx} | lines], acc) do
    build_map(lines, line_to_map(line, row_idx, acc))
  end

  defp line_to_map(line, row_idx, acc) do
    line
    |> to_charlist
    |> Enum.with_index
    |> Enum.reduce(acc, fn {char, col_idx}, acc2 -> Map.put(acc2, {row_idx, col_idx}, char) end)
  end

  defp find_units([], acc), do: elem(acc, 0)
  defp find_units([{line, row_idx} | lines], {acc, unit_idx}) do
    find_units(lines, line_to_units(line, row_idx, {acc, unit_idx}))
  end

  defp line_to_units(line, row_idx, {acc, unit_idx}) do
    line
    |> to_charlist
    |> Enum.with_index
    |> Enum.reduce({acc, unit_idx}, fn {char, col_idx}, {acc2, unit_idx2} ->
      cond do
        char in [@elf, @goblin] ->
          {
            [%{idx: unit_idx2, type: char, row: row_idx, col: col_idx, hitpoints: @hitpoints, done: false} | acc2],
            unit_idx2 + 1
          }
        true ->
          {acc2, unit_idx2}
      end
    end)
  end
end
