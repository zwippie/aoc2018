defmodule Aoc2018.Day17 do
  def solve do
    map = read_input()
    {{{min_x, _}, :clay}, {{max_x, _}, :clay}} =
      Enum.min_max_by(map, fn {{x, _y}, :clay} -> x end)
    {min_x, max_x} = {min_x - 1, max_x + 1}
    {{{_, min_y}, :clay}, {{_, max_y}, :clay}} =
      Enum.min_max_by(map, fn {{_x, y}, :clay} -> y end)

    add_water(map, {500, 1}, max_y)
    |> print_map({500, 0})
  end

  defp add_water(map, {500, 0}, _), do: map
  defp add_water(map, {_x, y}, max_y) when y > max_y, do: map
  defp add_water(map, {x, y} = pos, max_y) do
    print_map(map, pos)
    IO.gets("continue down with #{x}, #{y}")
    case Map.get(map, pos) do
      nil ->
        map = Map.put(map, pos, :flow)
        add_water(map, {x, y + 1}, max_y)

      :clay ->
        map
        |> add_water_left({x - 1, y - 1}, max_y)
        |> add_water_right({x + 1, y - 1}, max_y)
        |> add_water({x, y - 2}, max_y)

      :flow ->
        # look left and right
        map
        |> add_water_left({x - 1, y}, max_y)
        |> add_water_right({x + 1, y}, max_y)
        |> add_water({x, y - 1}, max_y)
    end
  end

  defp add_water_left(map, {x, y} = pos, max_y) do
    print_map(map, pos)
    IO.gets("continue left with #{x}, #{y}")
    case Map.get(map, pos) do
      nil ->
        map = Map.put(map, pos, :flow)

        # sand down?
        case Map.get(map, {x, y + 1}) do
          nil ->
            add_water(map, {x, y + 1}, max_y)

          _   ->
            # clay on the left?
            case Map.get(map, {x - 1, y}) do
              nil -> add_water_left(map, {x - 1, y}, max_y)
              _   -> map
            end
        end

      :clay ->
        waterify_if_possible(map, {x + 1, y})

      _ ->
        map
    end
  end

  defp add_water_right(map, {x, y} = pos, max_y) do
    print_map(map, pos)
    IO.gets("continue right with #{x}, #{y}")
    case Map.get(map, pos) do
      nil ->
        map = Map.put(map, pos, :flow)

        # sand down?
        case Map.get(map, {x, y + 1}) do
          nil ->
            add_water(map, {x, y + 1}, max_y)

          _   ->
            # clay on the right?
            case Map.get(map, {x + 1, y}) do
              nil -> add_water_right(map, {x + 1, y}, max_y)
              _   -> map
            end
        end

      :clay ->
        waterify_if_possible(map, {x - 1, y})

      _ ->
        map
    end
  end

  defp waterify_if_possible(map, {x, y} = pos) do
    IO.puts "waterify_if_possible at #{x}, #{y}"
    # is underground water or clay all the way to the left and right?
    if Map.get(map, {x - 1}) == :clay do
      # look right
      IO.puts "look right to waterify"
      map
    else
      # look left
      IO.puts "look left to waterify"
      map
    end
  end

  # defp add_water(map, {x, y} = pos, max_y) do
  #   IO.gets("continue")
  #   IO.inspect(pos)

  #   if Map.get(map, pos) == nil do
  #     # add water to pos that is assumed to be empty
  #     map = Map.put(map, pos, :water)
  #     print_map(map, pos)
  #     # look below
  #     case Map.get(map, {x, y + 1}) do
  #       nil ->
  #         add_water(map, {x, y + 1}, max_y)
  #       :water ->
  #         # spread left right? or stop..
  #         map
  #       :clay ->
  #         # spread left right
  #         map = Map.merge(
  #           add_water(map, {x - 1, y}, max_y),
  #           add_water(map, {x + 1, y}, max_y),
  #           fn
  #             _k, :water, nil -> :water
  #             _k, nil, :water -> :water
  #             _k, type, type  -> type
  #           end)
  #         add_water(map, {x, y - 1}, max_y)
  #     end
  #   else
  #     print_map(map, pos)
  #     map
  #   end
  # end

  defp print_map(map, {pos_x, pos_y} \\ {500, 0}) do
    {{{min_x, _}, _}, {{max_x, _}, _}} =
      Enum.min_max_by(map, fn {{x, _y}, _} -> x end)
    {min_x, max_x} = {min_x - 1, max_x + 1}
    {{{_, min_y}, _}, {{_, max_y}, _}} =
      Enum.min_max_by(map, fn {{_x, y}, _} -> y end)

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        if pos_x == x && pos_y == y do
          "o"
        else
          case Map.get(map, {x, y}, :sand) do
            :sand  -> "."
            :flow  -> "|"
            :water -> "~"
            :clay  -> "#"
          end
        end
      end
      |> Enum.join()
      |> IO.puts
    end

    map
  end

  defp read_input do
    File.read!("priv/fixtures/day17example.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&to_coords/1)
    |> Enum.reduce(%{}, &place_on_map/2)
    # |> Enum.reduce(%{{500, 0} => :well}, &place_on_map/2)
  end

  def to_coords(line) do
    line
    |> String.split(", ")
    |> Enum.map(&to_nr_or_range/1)
  end

  defp to_nr_or_range(term) do
    [dim, val] = String.split(term, "=")
    {dim, Code.eval_string(val) |> elem(0)}
  end

  defp place_on_map([{"x", x}, {"y", y_range}], acc) do
    Enum.reduce(y_range, acc, fn y, acc2 -> Map.put(acc2, {x, y}, :clay) end)
  end
  defp place_on_map([{"y", y}, {"x", x_range}], acc) do
    Enum.reduce(x_range, acc, fn x, acc2 -> Map.put(acc2, {x, y}, :clay) end)
  end
end
