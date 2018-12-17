defmodule Aoc2018.Day7 do
  @line_regex ~r/Step ([A-Z]) must be finished before step ([A-Z]) can begin./

  def solve do
    create_alphabet()
    |> remove_next_finished()
    |> Enum.reverse
    |> Enum.join
  end

  def create_alphabet do
    read_input()
    |> Enum.reduce(%{}, fn [from, to], acc ->
      Map.update(acc, to, [from], fn from_idxs -> [from | from_idxs] end)
    end)
    |> Enum.into(alphabet_kv())
  end

  defp remove_next_finished(alphabet, acc \\ []) do
    cond do
      Enum.empty?(alphabet) ->
        acc

      true ->
        {finished, []} = Enum.find(alphabet, fn {_k, v} -> length(v) == 0 end)
        alphabet
        |> Enum.map(fn {k, v} -> {k, v -- [finished]} end)
        |> Enum.into(%{})
        |> Map.delete(finished)
        |> remove_next_finished([finished | acc])
    end
  end

  defp alphabet_kv do
    ?A..?Z |> Enum.reduce(%{}, fn c, acc -> Map.put(acc, <<c>>, []) end)
  end

  defp read_input do
    File.read!("priv/fixtures/day7.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(&to_steps/1)
  end

  defp to_steps(line) do
    Regex.run(@line_regex, line, capture: :all_but_first)
  end
end

defmodule Aoc2018.Day7b do
  @no_workers 5

  def solve do
    Aoc2018.Day7.create_alphabet()
    |> next_tick()
  end

  defp next_tick(alphabet, tick \\ 0, workers \\ [], completed \\ [])
  defp next_tick(alphabet, tick, [], _completed) when alphabet == %{}, do: tick - 1
  defp next_tick(alphabet, tick, workers, completed) do
    # IO.inspect({tick, workers, alphabet, completed})
    {workers, finished} = handle_finished_workers(tick, workers)
    alphabet =
      alphabet
      |> Enum.map(fn {k, v} -> {k, v -- finished} end)
      |> Enum.into(%{})
      |> Map.drop(finished)
    {alphabet, workers} = add_workers(alphabet, workers, tick)
    next_tick(alphabet, tick + 1, workers, completed ++ finished)
  end

  defp add_workers(alphabet, workers, _tick) when length(workers) == @no_workers, do: {alphabet, workers}
  defp add_workers(alphabet, workers, _tick) when alphabet == %{}, do: {alphabet, workers}
  defp add_workers(alphabet, workers, tick) do
    case next_step(alphabet) do
      {char, []} ->
        alphabet = Map.delete(alphabet, char)
        workers = [{char, tick + :binary.first(char) - 4} | workers]
        add_workers(alphabet, workers, tick)

      nil ->
        {alphabet, workers}
    end
  end

  defp next_step(alphabet) do
    Enum.find(alphabet, fn {_k, v} -> Enum.empty?(v) end)
  end

  defp handle_finished_workers(tick, workers) do
    Enum.reduce(workers, {[], []}, fn {step, end_tick} = worker, {working, compl} ->
      cond do
        tick == end_tick ->
          {working, [step | compl]}

        true ->
          {[worker | working], compl}
      end
    end) # returns {workers, completed}
  end
end
