defmodule Aoc2018.Day11 do
  @puzzle_input 7857

  def solve do
    grid = create_grid(@puzzle_input)
    sliding_grid_coords()
    |> Enum.map(& {&1, region_power(grid, &1)})
    |> Enum.max_by(fn {_, level} -> level end)
  end

  defp region_power(input, {x, y}) do
    Map.get(input, {x,     y    }) +
    Map.get(input, {x + 1, y    }) +
    Map.get(input, {x + 2, y    }) +
    Map.get(input, {x,     y + 1}) +
    Map.get(input, {x + 1, y + 1}) +
    Map.get(input, {x + 2, y + 1}) +
    Map.get(input, {x,     y + 2}) +
    Map.get(input, {x + 1, y + 2}) +
    Map.get(input, {x + 2, y + 2})
  end

  defp sliding_grid_coords() do
    for y <- 1..298, x <- 1..298, do: {x, y}
  end

  defp create_grid(serial_nr) do
    (for y <- 1..300, x <- 1..300, do: {x, y})
    |> Map.new(&({&1, power_level(&1, serial_nr)}))
  end

  defp power_level({x, y}, serial_nr) do
    rack_id = x + 10
    power = (rack_id * y + serial_nr) * rack_id
    div(power, 100) |> rem(10) |> Kernel.-(5)
  end
end

defmodule Aoc2018.Day11b do
  @puzzle_input 7857

  def solve do
    grid = create_grid(@puzzle_input)

    1..300
    |> Stream.map(& {&1, find_max_power(grid, &1)})
    |> Enum.max_by(fn {_, {_, power}} -> power end)
  end

  defp find_max_power(grid, size) do
    sliding_grid_start_coords(size)
    |> Stream.map(& {&1, region_power(grid, &1, size)})
    |> Enum.max_by(fn {_, power} -> power end)
    |> IO.inspect(label: size)
  end

  defp region_power(grid, {x, y}, size) do
    sliding_grid_coords({x, y}, size)
    |> Enum.reduce(0, fn coord, acc -> acc + Map.get(grid, coord) end)
  end

  defp sliding_grid_coords({sx, sy}, size) do
    for y <- sy..(sy + size - 1), x <- sx..(sx + size - 1), do: {x, y}
  end

  defp sliding_grid_start_coords(size) do
    for y <- 1..(300 - size + 1), x <- 1..(300 - size + 1), do: {x, y}
  end

  defp create_grid(serial_nr) do
    (for y <- 1..300, x <- 1..300, do: {x, y})
    |> Map.new(&({&1, power_level(&1, serial_nr)}))
  end

  defp power_level({x, y}, serial_nr) do
    rack_id = x + 10
    power = (rack_id * y + serial_nr) * rack_id
    div(power, 100) |> rem(10) |> Kernel.-(5)
  end
end
