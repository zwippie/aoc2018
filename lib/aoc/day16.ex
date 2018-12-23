defmodule Aoc2018.Day16 do
  use Bitwise

  @opcodes ~w[addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr]a

  def solve do
    read_input()
    |> Enum.map(&try_opcodes/1)
    |> Enum.count(fn {_op, codes} -> length(codes) >= 3 end)
  end

  def solve_b do
    opcodes =
      read_input()
      |> Enum.map(&try_opcodes/1)
      |> Map.new
      |> find_opcodes(%{})

    read_program()
    |> Enum.map(fn {op, a, b, c} -> {Map.get(opcodes, op), a, b, c} end)
    |> run_program([0, 0, 0, 0])
  end

  defp run_program([], registers), do: registers
  defp run_program([head | tail], registers) do
    run_program(tail, execute(head, registers))
  end

  defp find_opcodes(opcodes, acc) when opcodes == %{}, do: acc
  defp find_opcodes(opcodes, acc) do
    {op, [code]} = Enum.find(opcodes, fn {_, codes} -> length(codes) == 1 end)
    acc = Map.put(acc, op, code)
    opcodes
    |> Map.delete(op)
    |> Enum.map(fn {op, codes} -> {op, List.delete(codes, code)} end)
    |> Map.new
    |> find_opcodes(acc)
  end

  defp try_opcodes({regs_before, {op, a, b, c}, regs_after}) do
    {
      op,
      Enum.reduce(@opcodes, [], fn opcode, acc ->
        if execute({opcode, a, b, c}, regs_before) == regs_after do
          [opcode | acc]
        else
          acc
        end
      end)
    }
  end

  defp execute({:addr, a, b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a) + Enum.at(registers, b))
  end
  defp execute({:addi, a, b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a) + b)
  end

  defp execute({:mulr, a, b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a) * Enum.at(registers, b))
  end
  defp execute({:muli, a, b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a) * b)
  end

  defp execute({:banr, a, b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a) &&& Enum.at(registers, b))
  end
  defp execute({:bani, a, b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a) &&& b)
  end

  defp execute({:borr, a, b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a) ||| Enum.at(registers, b))
  end
  defp execute({:bori, a, b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a) ||| b)
  end

  defp execute({:setr, a, _b, c}, registers) do
    List.replace_at(registers, c, Enum.at(registers, a))
  end
  defp execute({:seti, a, _b, c}, registers) do
    List.replace_at(registers, c, a)
  end

  defp execute({:gtir, a, b, c}, registers) do
    List.update_at(registers, c, fn _ -> if a > Enum.at(registers, b), do: 1, else: 0 end)
  end
  defp execute({:gtri, a, b, c}, registers) do
    List.update_at(registers, c, fn _ -> if Enum.at(registers, a) > b, do: 1, else: 0 end)
  end
  defp execute({:gtrr, a, b, c}, registers) do
    List.update_at(registers, c, fn _ -> if Enum.at(registers, a) > Enum.at(registers, b), do: 1, else: 0 end)
  end

  defp execute({:eqir, a, b, c}, registers) do
    List.update_at(registers, c, fn _ -> if a == Enum.at(registers, b), do: 1, else: 0 end)
  end
  defp execute({:eqri, a, b, c}, registers) do
    List.update_at(registers, c, fn _ -> if Enum.at(registers, a) == b, do: 1, else: 0 end)
  end
  defp execute({:eqrr, a, b, c}, registers) do
    List.update_at(registers, c, fn _ -> if Enum.at(registers, a) == Enum.at(registers, b), do: 1, else: 0 end)
  end


  defp read_input do
    File.read!("priv/fixtures/day16.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.take(2337)
    |> Enum.chunk_every(3)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line([regs_before, op, regs_after]) do
    {regs_before, []} = regs_before |> String.replace("Before: ", "") |> Code.eval_string
    {regs_after, []} = regs_after |> String.replace("After: ", "") |> Code.eval_string
    op = parse_program_line(op)
    {regs_before, op, regs_after}
  end

  defp read_program do
    File.read!("priv/fixtures/day16.txt")
    |> String.split(~r/\n/, trim: true)
    |> Enum.drop(2337)
    |> Enum.map(&parse_program_line/1)
  end

  defp parse_program_line(line) do
    String.split(line, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end

defmodule Aoc2018.Day16b do
  def solve do
    Aoc2018.Day16.solve_b
  end
end
