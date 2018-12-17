defmodule Aoc2018.DayInfiMaze do
  alias Aoc2018.DayInfiMaze

  defstruct cells: [], no_cols: 0, no_rows: 0

  defmodule Cell do
    defstruct idx: 0, to: []
  end

  def solve do
    maze = read_input() |> to_maze()
    find_exit(maze, 0, length(maze.cells) - 1, [])
    |> Enum.chunk_by(fn x -> x == 0 end)
    |> Enum.map(&length/1)
    |> Enum.reject(&(&1 == 1))
    |> Enum.min
  end

  def find_exit(%DayInfiMaze{} = maze, current_idx, exit_idx, visited) do
    cond do
      current_idx == exit_idx ->
        [current_idx | visited] |> List.flatten |> IO.inspect

      current_idx in visited ->
        []

      true ->
        cell = Enum.at(maze.cells, current_idx)
        Enum.map(cell.to, fn to_idx ->
          find_exit(maze, to_idx, exit_idx, [current_idx | visited])
        end)
        # |> Enum.reject(&Enum.empty?/1)
        |> List.flatten
    end
  end

  # connections
  defp to_maze(%DayInfiMaze{} = maze) do
    cells =
      maze.cells
      |> Enum.with_index
      |> Enum.map(&to_cell(maze, &1))
    Map.put(maze, :cells, cells)
  end

  defp to_cell(%DayInfiMaze{} = maze, {char, idx}) do
    to =
      char
      |> char_directions
      |> Enum.map(&find_connections(maze, idx, &1))
      |> Enum.reject(&is_nil/1)

    %DayInfiMaze.Cell{idx: idx, to: to}
  end

  defp find_connections(%DayInfiMaze{} = maze, idx, :up) do
    other_idx = idx - maze.no_cols
    cond do
      other_idx < 0 -> nil
      true ->
        other_cell = Enum.at(maze.cells, other_idx)
        cond do
          :down in char_directions(other_cell) -> other_idx
          true -> nil
        end
    end
  end

  defp find_connections(%DayInfiMaze{} = maze, idx, :down) do
    other_idx = idx + maze.no_cols
    cond do
      other_idx >= (maze.no_rows * maze.no_cols) -> nil
      true ->
        other_cell = Enum.at(maze.cells, other_idx)
        cond do
          :up in char_directions(other_cell) -> other_idx
          true -> nil
        end
    end
  end

  defp find_connections(%DayInfiMaze{} = maze, idx, :left) do
    other_idx = cond do
      rem(idx, maze.no_cols) == 0 -> nil
      true -> idx - 1
    end
    cond do
      is_nil(other_idx) -> nil
      true ->
        other_cell = Enum.at(maze.cells, other_idx)
        cond do
          :right in char_directions(other_cell) -> other_idx
          true -> nil
        end
    end
  end

  defp find_connections(%DayInfiMaze{} = maze, idx, :right) do
    other_idx = cond do
      rem(idx + 1, maze.no_cols) == 0 -> nil
      true -> idx + 1
    end
    cond do
      is_nil(other_idx) -> nil
      true ->
        other_cell = Enum.at(maze.cells, other_idx)
        cond do
          :left in char_directions(other_cell) -> other_idx
          true -> nil
        end
    end
  end

  defp char_directions("║"), do: [:up, :down]
  defp char_directions("╔"), do: [:right, :down]
  defp char_directions("╗"), do: [:left, :down]
  defp char_directions("╠"), do: [:up, :down, :right]
  defp char_directions("╦"), do: [:left, :down, :right]
  defp char_directions("╚"), do: [:up, :right]
  defp char_directions("╝"), do: [:up, :left]
  defp char_directions("╬"), do: [:up, :down, :left, :right]
  defp char_directions("╩"), do: [:left, :up, :right]
  defp char_directions("═"), do: [:left, :right]
  defp char_directions("╣"), do: [:left, :up, :down]

  defp read_input do
    data =
      File.read!("priv/fixtures/infi_maze.txt")
      |> String.split(~r/\n/, trim: true)
    no_rows = data |> length
    no_cols = data |> hd |> String.length
    cells =
      data
      |> Enum.map(&String.split(&1, "", trim: true))
      |> List.flatten
    %DayInfiMaze{cells: cells, no_rows: no_rows, no_cols: no_cols}
  end
end
