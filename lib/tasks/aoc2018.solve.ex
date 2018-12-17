defmodule Mix.Tasks.Aoc2018.Solve do
  use Mix.Task

  @shortdoc "Solve the problem of excercise <argument> and show the result"

  def run([excercise]) do
    Module.safe_concat([Aoc2018, excercise])
    |> apply(:solve, [])
    |> IO.inspect
  end
end
