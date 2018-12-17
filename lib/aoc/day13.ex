defmodule Aoc2018.Day13 do
  def solve do
    grid   = read_input() |> make_grid()
    trains = read_input() |> find_trains() # |> IO.inspect
    move_trains(trains, grid)
  end

  defp move_trains(trains, grid, count \\ 1) do
    # IO.inspect count
    trains =
      trains
      |> sort_trains
      |> Enum.map(&move_train(&1, grid, trains))
      # |> IO.inspect

    if has_collissions(trains) do
      {count, trains}
    else
      move_trains(trains, grid, count + 1)
    end
  end

  defp move_train(train, grid, trains) do
    train = case train.dir do
      :left  -> %{train | row: train.row, col: train.col - 1}
      :right -> %{train | row: train.row, col: train.col + 1}
      :up    -> %{train | row: train.row - 1, col: train.col}
      :down  -> %{train | row: train.row + 1, col: train.col}
    end

    if has_collissions([train | trains]) do
      raise "Kaboom at #{train.col},#{train.row}"
    end

    grid
    |> Map.fetch!({train.row, train.col})
    |> set_new_dir(train)
  end

  # When a train arrives at segment from dir, which dir does it go next?
  defp set_new_dir(segment, train) do
    case {segment, train.dir} do
      {?\\, :left}  -> %{train | dir: :up}
      {?\\, :right} -> %{train | dir: :down}
      {?\\, :up}    -> %{train | dir: :left}
      {?\\, :down}  -> %{train | dir: :right}
      {?/ , :left}  -> %{train | dir: :down}
      {?/ , :right} -> %{train | dir: :up}
      {?/ , :up}    -> %{train | dir: :right}
      {?/ , :down}  -> %{train | dir: :left}
      {?+ , _}      -> take_next_turn(train)
      _             -> train
    end
  end

  # take next turn on crossing
  defp take_next_turn(%{next_turn: next_turn, dir: dir} = train) do
    case {next_turn, dir} do
      {:left, :left}  -> %{train | next_turn: :up, dir: :down}
      {:left, :right} -> %{train | next_turn: :up, dir: :up}
      {:left, :up}    -> %{train | next_turn: :up, dir: :left}
      {:left, :down}  -> %{train | next_turn: :up, dir: :right}

      {:up, :left}  -> %{train | next_turn: :right, dir: :left}
      {:up, :right} -> %{train | next_turn: :right, dir: :right}
      {:up, :up}    -> %{train | next_turn: :right, dir: :up}
      {:up, :down}  -> %{train | next_turn: :right, dir: :down}

      {:right, :left}  -> %{train | next_turn: :left, dir: :up}
      {:right, :right} -> %{train | next_turn: :left, dir: :down}
      {:right, :up}    -> %{train | next_turn: :left, dir: :right}
      {:right, :down}  -> %{train | next_turn: :left, dir: :left}
    end
  end

  defp has_collissions(trains) do
    trains
    |> Enum.map(fn train -> {train.row, train.col} end)
    |> Enum.uniq
    |> length
    |> Kernel.!=(length(trains))
  end

  defp sort_trains(trains) do
    Enum.sort_by(trains, fn train -> train.row * 200 + train.col end)
  end

  # Handle input

  defp read_input do
    File.read!("priv/fixtures/day13.txt")
    |> String.split(~r/\n/, trim: true)
  end

  defp find_trains(input) do
    input
    |> Enum.with_index
    |> Enum.reduce([], &line_to_trains/2)
  end

  defp line_to_trains({line, row_idx}, trains) do
    line
    |> to_charlist
    |> Enum.with_index
    |> Enum.reduce(trains, fn {char, col_idx}, acc ->
      case char do
        ?< -> [%{next_turn: :left, row: row_idx, col: col_idx, dir: :left} | acc] # <
        ?> -> [%{next_turn: :left, row: row_idx, col: col_idx, dir: :right} | acc] # >
        ?^ -> [%{next_turn: :left, row: row_idx, col: col_idx, dir: :up} | acc] # ^
        ?v -> [%{next_turn: :left, row: row_idx, col: col_idx, dir: :down} | acc] # v
        _  -> acc
      end
    end)
  end

  defp make_grid(input) do
    input
    |> Enum.with_index
    |> Enum.reduce(%{}, &line_to_grid/2)
  end

  defp line_to_grid({line, row_idx}, grid) do
    line
    |> to_charlist
    |> Enum.with_index
    |> Enum.reduce(grid, fn {char, col_idx}, acc ->
      case char do
        32  -> acc
        ?<  -> Map.put(acc, {row_idx, col_idx}, ?-) # < wordt -
        ?>  -> Map.put(acc, {row_idx, col_idx}, ?-) # >
        ?^  -> Map.put(acc, {row_idx, col_idx}, ?|) # ^ wordt |
        ?v  -> Map.put(acc, {row_idx, col_idx}, ?|) # v
        _   -> Map.put(acc, {row_idx, col_idx}, char)
      end
    end)
  end
end
