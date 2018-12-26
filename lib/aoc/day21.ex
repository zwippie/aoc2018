defmodule Aoc2018.Day21 do
  use Bitwise

  def solve do
    {ip_idx, program} = read_program("priv/fixtures/day21.txt")
    registers = List.duplicate(0, 6) |> List.replace_at(ip_idx, -1)

    Stream.unfold(3909249, fn num -> {num, num + 1} end)
    |> Stream.each(fn x ->
      IO.inspect(x)
      run_program(program, ip_idx, List.replace_at(registers, 0, x), 0)
    end)
    |> Enum.to_list
  end

  # 9540017 too low
  def solve_b do
    {ip_idx, program} = read_program("priv/fixtures/day21.txt")
    registers = List.duplicate(0, 6) |> List.replace_at(ip_idx, -1) # |> List.replace_at(0, 1)
    run_program(program, ip_idx, registers, 0)
  end

  defp run_program(_, _, registers, 10_000), do: registers
  defp run_program(program, ip_idx, registers, counter) do
    registers = List.update_at(registers, ip_idx, &(&1 + 1))
    ip = Enum.at(registers, ip_idx)
    instruction = Enum.at(program, ip)
    # IO.inspect(registers)
    # IO.gets(instruction |> Tuple.to_list |> Enum.join(" "))
    registers = execute(instruction, registers)
    run_program(program, ip_idx, registers, counter + 1)
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
    IO.inspect(registers, label: "if d == a")
    List.update_at(registers, c, fn _ -> if Enum.at(registers, a) == Enum.at(registers, b), do: 1, else: 0 end)
  end

  defp read_program(filename) do
    [ip | program] =
      File.read!(filename)
      |> String.split(~r/\n/, trim: true)
    ip = String.replace(ip, "#ip ", "") |> String.to_integer
    {ip, Enum.map(program, &parse_program_line/1)}
  end

  defp parse_program_line(line) do
    [op, a, b, c] = String.split(line, " ", trim: true)
    {
      String.to_atom(op),
      String.to_integer(a),
      String.to_integer(b),
      String.to_integer(c)
    }
  end
end

defmodule Aoc2018.Day21b do
  def solve do
    Aoc2018.Day21.solve_b
  end
end
