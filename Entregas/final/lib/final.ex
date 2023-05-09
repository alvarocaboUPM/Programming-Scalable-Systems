defmodule Final do
  @moduledoc """
  Documentation for `Final`.
  """
  def date_parts(date_str) do
    String.split(date_str, "-")
    |> Enum.map(&String.to_integer/1)
  end

  @spec fibs(pos_integer()) :: [pos_integer()]
  def fibs(n) when n > 0 do
    fibs(n, [0, 1])
  end

  defp fibs(1, fib_list) do
    Enum.reverse(fib_list)
  end

  defp fibs(n, [fib_n_minus_1, fib_n_minus_2 | fib_list]) do
    fib_n = fib_n_minus_1 + fib_n_minus_2
    fibs(n - 1, [fib_n, fib_n_minus_1, fib_n_minus_2 | fib_list])
  end

  @spec map([a], (a -> b)) :: [b]
  def map(list, func) do
    for item <- list, do: func.(item)
  end

  @spec reduce([a], b, ((a, b) -> b)) :: b
  def reduce(list, acc, func) do
    Enum.reduce(list, acc, func)
  end

  @spec filter([a], (a -> boolean())) :: [a]
  def filter(list, func) do
    Enum.filter(list, func)
  end

end
