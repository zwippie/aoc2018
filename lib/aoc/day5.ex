defmodule Aoc2018.Day5 do
  @regex ~r/Aa|aA|Bb|bB|Cc|cC|Dd|dD|Ee|eE|Ff|fF|Gg|gG|Hh|hH|Ii|iI|Jj|jJ|Kk|kK|Ll|lL|Mm|mM|Nn|nN|Oo|oO|Pp|pP|Qq|qQ|Rr|rR|Ss|sS|Tt|tT|Uu|uU|Vv|vV|Ww|wW|Xx|xX|Yy|yY|Zz|zZ/

  def solve do
    read_input()
    |> remove_next_pair()
    |> String.length
  end

  defp remove_next_pair(input) do
    case Regex.run(@regex, input, return: :index) do
      [{0, 2}] ->
        String.slice(input, 2..-1)
        |> remove_next_pair

      [{idx, 2}] ->
        String.slice(input, 0..(idx - 1)) <> String.slice(input, (idx + 2)..-1)
        |> remove_next_pair

      _ ->
        input
    end
  end

  defp build_regex do
    for caps <- ?A..?Z do
      small = caps + 32
      [caps, small, ?|, small, caps]
    end
    |> Enum.join("|")
  end

  defp read_input do
    File.read!("priv/fixtures/day5.txt")
    |> String.split(~r/\n/, trim: true)
    |> hd
  end
end
