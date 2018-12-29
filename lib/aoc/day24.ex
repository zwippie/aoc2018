defmodule Aoc2018.Day24 do
  @line_regex ~r/(\d+) units each with (\d+) hit points with an attack that does (\d+) (cold|fire|radiation|slashing|bludgeoning) damage at initiative (\d+)/
  @weaknesses_regex ~r/weak to (\w+)(?>, (\w+))?(?>, (\w+))?/
  @immunities_regex ~r/immune to (\w+)(?>, (\w+))?(?>, (\w+))?/

  def solve do
    read_input()
    |> fight
    |> Enum.reduce(0, fn group, acc -> acc + group.no_units end)
  end

  def solve_b do
    groups = read_input()
    25..5000
    |> Enum.reduce_while(0, fn boost, acc ->
      groups_left =
        groups
        |> give_boost(boost)
        |> fight

      # print_armies(groups_left)
      # Enum.each(groups_left, &IO.inspect/1)

      infection_count = Enum.count(groups_left, fn group -> group.army == :infection end)
      immune_system_count = Enum.count(groups_left, fn group -> group.army == :immune_system end)

      case {infection_count, immune_system_count} do
        {0, _} ->
          IO.puts "immune_system wins with boost of #{boost}"
          unit_count = Enum.reduce(groups_left, 0, fn group, acc2 -> acc2 + group.no_units end)
          {:halt, unit_count}

        {_, 0} ->
          IO.puts "immune_system was slaughtered with boost of #{boost}"
          {:cont, acc}

        {_, _} ->
          IO.puts "stalemate with boost of #{boost}"
          {:cont, acc}
      end
    end)
  end

  defp fight(groups) do
    # IO.gets print_armies(groups)
    # print_armies(groups)
    groups = sort_for_attack(groups)

    attacks =
      groups
      |> sort_for_target_selection
      |> Enum.reduce(%{}, &find_target(groups, &1, &2))

    cond do
      Enum.empty?(attacks) ->
        groups

      true ->
        {groups, death_count} = attack(groups, attacks)
        if death_count == 0 do
          IO.puts "No one is dying from these attacks"
          groups
        else
          groups
          |> Enum.reject(fn group -> group.no_units == 0 end)
          |> fight
        end
    end
  end

  defp attack(groups, attacks) do
    Enum.reduce(groups, {groups, 0}, fn attacker, {acc, death_count} ->
      attacker = Enum.find(acc, fn group -> group.initiative == attacker.initiative end)
      case Enum.find(attacks, fn {_ti, ai} -> attacker.initiative == ai end) do
        nil ->
          {acc, death_count}

        {target_initiative, _} ->
          target_idx = Enum.find_index(acc, fn group -> group.initiative == target_initiative end)
          target = Enum.at(acc, target_idx)
          damage = damage_done(attacker, target)
          units_lost = Enum.min([target.no_units, div(damage, target.hit_points)])
          # IO.puts "#{attacker.army} #{attacker.group} attacks #{target.group} with #{attacker.no_units} units doing #{damage} damage, killing #{units_lost} units"
          no_units = target.no_units - units_lost
          {List.replace_at(acc, target_idx, %{target | no_units: no_units}), death_count + units_lost}
      end
    end)
  end

  defp find_target(groups, current_group, acc) do
    groups
    |> Enum.reject(fn group -> Map.has_key?(acc, group.initiative) end)
    |> Enum.reject(fn group -> group.army == current_group.army end)
    |> Enum.map(fn group -> {group, damage_done(current_group, group), effective_power(group)} end)
    |> Enum.reject(fn {_, damage, _} -> damage == 0 end)
    |> Enum.sort_by(&{elem(&1, 1), elem(&1, 2)}, &>=/2)
    |> case do
      [] ->
        acc

      targets ->
        {target, _, _} = hd(targets)
         Map.put(acc, target.initiative, current_group.initiative)
    end
    # |> IO.inspect
  end

  defp sort_for_target_selection(groups) do
    Enum.sort_by(groups, &{effective_power(&1), Map.get(&1, :initiative)}, &>=/2)
  end

  defp sort_by_army_and_group(groups) do
    Enum.sort_by(groups, &{Map.get(&1, :army), Map.get(&1, :group)})
  end

  defp sort_for_attack(groups) do
    Enum.sort_by(groups, &Map.get(&1, :initiative), &>=/2)
  end

  defp effective_power(group) do
    group.no_units * group.damage
  end

  defp damage_done(from, to) do
    cond do
      from.damage_type in to.immunities -> 0
      from.damage_type in to.weaknesses -> 2 * effective_power(from)
      true -> effective_power(from)
    end
  end

  defp give_boost(groups, boost) do
    Enum.map(groups, fn group ->
      case group.army do
        :infection -> group
        :immune_system -> %{group | damage: group.damage + boost}
      end
    end)
  end

  defp print_armies(groups) do
    IO.puts ""
    groups
    |> sort_by_army_and_group
    |> Enum.each(fn group -> IO.puts("#{group.army} #{group.group} with #{group.no_units} units") end)
  end

  defp read_input do
    {immune_system, infection} =
      File.read!("priv/fixtures/day24.txt")
      |> String.split(~r/\n/, trim: true)
      |> Enum.split_while(&(&1 != "Infection:"))

    immune_system =
      immune_system
      |> tl
      |> Enum.with_index(1)
      |> Enum.map(&parse_line(&1, :immune_system))

    infection =
      infection
      |> tl
      |> Enum.with_index(1)
      |> Enum.map(&parse_line(&1, :infection))

    immune_system ++ infection
  end

  defp parse_line({line, idx}, army) do
    {global, special} =
      case String.splitter(line, ["(", ") "]) |> Enum.to_list do
        [line] -> {line, nil}
        [first, special, last] -> {first <> last, special}
      end

    [no_units, hit_points, damage, damage_type, initiative] =
      Regex.scan(@line_regex, global, capture: :all_but_first) |> hd
    %{
      army: army,
      group: idx,
      no_units: String.to_integer(no_units),
      hit_points: String.to_integer(hit_points),
      damage: String.to_integer(damage),
      damage_type: String.to_atom(damage_type),
      initiative: String.to_integer(initiative),
      weaknesses: find_weaknesses(special),
      immunities: find_immunities(special),
      current_target: nil
    }
  end

  defp find_weaknesses(nil), do: []
  defp find_weaknesses(str) do
    case Regex.scan(@weaknesses_regex, str, capture: :all_but_first) do
      [] -> []
      [result] -> Enum.map(result, &String.to_atom/1)
    end
  end

  defp find_immunities(nil), do: []
  defp find_immunities(str) do
    case Regex.scan(@immunities_regex, str, capture: :all_but_first) do
      [] -> []
      [result] -> Enum.map(result, &String.to_atom/1)
    end
  end
end

defmodule Aoc2018.Day24b do
  def solve do
    Aoc2018.Day24.solve_b
  end
end
