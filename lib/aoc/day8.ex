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
    File.read!("priv/fixtures/day8example.txt")
    |> String.split(~r/\W/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
