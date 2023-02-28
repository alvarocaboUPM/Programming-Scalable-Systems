defmodule Sheet2 do
  @doc """
  Define a recursive function
  such that fib(n)returns the nth element of the Fibonacci sequence
  """
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n) when n > 1 do
    fib(n - 1) + fib(n - 2)
  end
  
end
