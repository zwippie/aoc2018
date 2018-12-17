defmodule Aoc2018.Day4 do
  @line_regex ~r/\[(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})\] (.+)/
  @action_regex ~r/\#(\d+)/

  def solve do
    {id, minutes} =
      create_schedule()
      |> Enum.max_by(&total_sleep_minutes/1, fn -> 0 end)

    {minute, _} = Enum.max_by(minutes, fn {_k, v} -> v end)

    String.to_integer(id) * minute
  end

  def solve_b do
    {id, {minute, _}} =
      create_schedule()
      |> Enum.map(&max_sleep_minute/1)
      |> Enum.max_by(fn {_, {_, time}} -> time end)

   String.to_integer(id) * minute
  end

  defp create_schedule do
    read_input()
    |> Enum.map(&parse_line/1)
    |> sort_lines()
    |> Enum.reduce({"dummy_id", []}, &action_reducer/2)
    |> elem(1)
    |> Enum.reverse
    |> Enum.group_by(&(elem(&1, 1))) # group by guard id
    |> Enum.map(&sleep_minutes/1)
  end

  defp max_sleep_minute({id, minutes}) do
    {id, Enum.max_by(minutes, fn {_k, v} -> v end, fn -> {0, 0} end)}
  end

  defp total_sleep_minutes({_id, minutes}) do
    Enum.reduce(minutes, 0, fn {_, time}, acc -> acc + time end)
  end

  defp sleep_minutes({id, entries}) do
    entries
    |> Enum.reject(fn {_, _, action} -> action == :start end)
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, &add_sleep_minutes/2)
    |> (& {id, &1}).()
  end

  defp add_sleep_minutes([{from, _, :sleep}, {to, _, :wake}], acc) do
    from.minute..(to.minute - 1)
    |> Enum.reduce(acc, fn minute, acc2 -> Map.update(acc2, minute, 1, &(&1+1)) end)
  end

  defp action_reducer({date, action}, {id, actions}) do
    case parse_action(action) do
      :sleep -> {id, [{date, id, :sleep} | actions]}
      :wake -> {id, [{date, id, :wake} | actions]}
      {:start, id} -> {id, [{date, id, :start} | actions]}
    end
  end

  defp sort_lines(lines) do
    Enum.sort_by(lines, &(elem(&1, 0)), &(NaiveDateTime.compare(&1, &2) == :lt))
  end

  defp parse_line(line) do
    with [parsed_line] <- Regex.scan(@line_regex, line, capture: :all_but_first),
         {date_parts, [action]} <- Enum.split(parsed_line, -1),
         [year, month, day, hours, minutes] <- Enum.map(date_parts, &String.to_integer/1),
         {:ok, date} <- NaiveDateTime.new(year, month, day, hours, minutes, 0) do
      {date, action}
    end
  end

  defp parse_action("falls asleep"), do: :sleep
  defp parse_action("wakes up"), do: :wake
  defp parse_action(action) do
    [[id]] = Regex.scan(@action_regex, action, capture: :all_but_first)
    {:start, id}
  end

  defp read_input do
    File.read!("priv/fixtures/day4.txt")
    |> String.split(~r/\n/, trim: true)
  end
end

defmodule Aoc2018.Day4b do
  def solve do
    Aoc2018.Day4.solve_b()
  end
end
