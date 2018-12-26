defmodule Aoc2018.Day20 do
  def solve do
    input = "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$"
    # input = "(ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN)"
    # input = "ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN)"

    input
    |> String.split("", trim: true)
    # |> to_nodes(nil, nil)
    # |> Enum.reduce([], &find_next_segment)
    |> to_routes()
  end

  # defp to_routes(input, level \\ 0, prev_split \\ "", curr \\ "", acc \\ [])
  defp to_routes(["^" | tail]) do
    to_routes(tail, 1, "", "", [])
  end
  defp to_routes(["$"], 1, _prev_split, curr, acc) do
    [curr | acc]
  end
  defp to_routes([head | tail], level, prev_split, curr, acc) do
    case head do
      "(" ->
        segments = to_routes(tail, level + 1, curr, curr, acc)

      "|" ->
        segments = to_routes(tail, level, prev_split, prev_split, acc)
        to_routes(tail, level, prev_split, prev_split, acc ++ segments)

      ")" ->
        to_routes(tail, level - 1, prev_split, curr, acc)
        # to_routes(tail, level, prev_split, prev_split, acc ++ segments)

      _ ->
        # IO.inspect({tail, level, prev_split, curr, head, acc})
        to_routes(tail, level, prev_split, curr <> head, acc)
    end
  end

  # defp to_segments([head | tail], level) do
  #   case head do

  #   end
  # end

end
