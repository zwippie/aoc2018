defmodule Aoc2018.Day8 do
  def solve do
    read_input()
    |> next_node([])
    |> elem(1)
    |> Enum.sum
  end

  defp next_node([no_nodes, no_meta | input], meta) do
    # IO.inspect({no_nodes, no_meta, input, meta})
    {rest, new_meta} =
      List.duplicate(1, no_nodes)
      |> Enum.reduce({input, []}, fn _, {rest, acc} ->
        next_node(rest, acc)
      end)

    {new_new_meta, rest} = Enum.split(rest, no_meta)
    {rest, meta ++ new_meta ++ new_new_meta}
  end

  defp read_input do
    File.read!("priv/fixtures/day8.txt")
    |> String.split(~r/\W/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Aoc2018.Day8b do
  def solve do
    read_input()
    |> next_node([])
    |> elem(1)
    |> Enum.sum
  end

  defp next_node([0, no_meta | input], meta) do
    {new_meta, rest} = Enum.split(input, no_meta)
    sum = Enum.sum(new_meta)
    {rest, meta ++ [sum]}
  end
  defp next_node([no_nodes, no_meta | input], meta) do
    {rest, new_meta} =
      List.duplicate(1, no_nodes)
      |> Enum.reduce({input, []}, fn _, {rest, acc} ->
        next_node(rest, acc)
      end)

    {meta_idxs, rest} = Enum.split(rest, no_meta)
    new_new_meta = Enum.reduce(meta_idxs, 0, fn idx, acc -> acc + Enum.at(new_meta, idx - 1, 0) end)
    {rest, meta ++ [new_new_meta]}
  end

  defp read_input do
    File.read!("priv/fixtures/day8.txt")
    |> String.split(~r/\W/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
