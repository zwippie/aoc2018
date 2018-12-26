defmodule Aoc2018.Day22Naive do
  @magic 20183
  # @depth 510
  # @target_pos {10, 10}

  @depth 3339
  @target_pos {10, 715}

  def solve do
    {max_x, max_y} = @target_pos
    for x <- 0..max_x, y <- 0..max_y do
      type({x, y})
    end
    |> Enum.sum
  end


  defp geologic_index(pos) when pos == @target_pos do
    0
  end

  defp geologic_index({0, y}) do
    y * 48271
  end

  defp geologic_index({x, 0}) do
    x * 16807
  end

  defp geologic_index({x, y}) do
    erosion_level({x - 1, y}) * erosion_level({x, y - 1})
  end

  defp erosion_level(pos) do
    rem(geologic_index(pos) + @depth, @magic)
  end

  defp type(pos) do
    rem(erosion_level(pos), 3)
  end
end

defmodule Aoc2018.Day22 do
  @magic 20183
  @depth 510
  @target_pos {10, 10}

  # @depth 3339
  # @target_pos {10, 715}

  def solve do
    @target_pos
    |> types
    |> Map.values
    |> Enum.sum
  end

  def types(target_pos) do
    {max_x, max_y} = target_pos
    geo_indexes = geologic_indexes(target_pos)
    for x <- 0..max_x, y <- 0..max_y do
      {{x, y}, type(geo_indexes, {x, y})}
    end
    |> Map.new
  end

  defp geologic_indexes(target_pos) do
    {max_x, max_y} = target_pos
    0..max_x
    |> Enum.reduce(%{}, fn x, acc ->
      Enum.reduce(0..max_y, acc, fn y, acc2 ->
        Map.put(acc2, {x, y}, geologic_index(acc2, {x, y}))
      end)
    end)
  end

  defp geologic_index(_, pos) when pos == @target_pos do
    0
  end

  defp geologic_index(_, {0, y}) do
    y * 48271
  end

  defp geologic_index(_, {x, 0}) do
    x * 16807
  end

  defp geologic_index(geologic_indexes, {x, y}) do
    erosion_level(geologic_indexes, {x - 1, y}) * erosion_level(geologic_indexes, {x, y - 1})
  end

  defp erosion_level(geologic_indexes, pos) do
    rem(Map.get(geologic_indexes, pos) + @depth, @magic)
  end

  defp type(geologic_indexes, pos) do
    rem(erosion_level(geologic_indexes, pos), 3)
  end
end

defmodule Aoc2018.Day22b do
  @target_pos {10, 10}
  @extra 5
  # @target_pos {10, 715}
  # @extra 50

  def solve do
    {max_x, max_y} = @target_pos
    cell_types = Aoc2018.Day22.types({max_x + @extra, max_y + @extra})

    find_shortest_route(cell_types, {0, 0}, tool, 0, [])
  end

  defp find_shortest_route(cell_types, {x, y} = from, tool, duration, acc) do
    to = {x - 1, y}
    {tool, cost} = prepare_for(cell_types, tool, from, to)
    find_shortest_route(cell_types, to, duration + cost() )
  end

  defp prepare_for(cell_types, tool, from, to) do
    can_move_to?(Map.get(cell_types, from), Map.get(cell_types, to))
  end

  defp distance({from_x, from_y}, {to_x, to_y}) do
    abs(to_x - from_x) + abs(to_y - from_y)
  end

  defp to_coords(from) do

  end

  defp tools_for(cell_type) do
    case cell_type do
      0 -> [:climbing_gear, :torch]
      1 -> [:climbing_gear, :neither]
      2 -> [:torch, :neither]
    end
  end

  defp change_needed?(tool, to_type) do
    tool not in tools_for(to_type)
  end

  defp can_move_to?(from_type, to_type) do
    tools_from = tools_for(from_type) |> MapSet.new()
    tools_to   = tools_for(to_type)   |> MapSet.new()
    MapSet.union(tools_from, tools_to) |> Enum.any?
  end

  # when adjacent, what is the cost/duration to move?
  defp cost(cell_types, tool, to) do
    if change_needed?(tool, Map.get(cell_types, to)), do: 7, else: 1
  end
end
