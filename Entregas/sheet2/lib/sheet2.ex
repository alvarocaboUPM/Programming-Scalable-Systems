defmodule Sheet2 do
  @moduledoc """
    Ejercicios Sheet2 Programming Scalable Systems
  """

  @doc """
  Define a recursive function
  such that fib(n)returns the nth element of the Fibonacci sequence
  """
  def fib(0), do: 0
  def fib(1), do: 1

  def fib(n) when n > 1 do
    fib(n - 1) + fib(n - 2)
  end

  @doc """
  Define a recursive function that gcd(n,m)returns the
  greatest com-mon divisor of n and m using Euclid’s algorithm
  """
  def gcd(n, m) when n == m, do: n
  def gcd(n, 0), do: n
  def gcd(0, m), do: m
  def gcd(n, m) when n < m, do: gcd(m, n)

  def gcd(n, m) do
    r = rem(n, m)
    gcd(m, r)
  end

  @doc """
  3. Fibonacci revisited
  """
  def fibs(0), do: []
  def fibs(1), do: [0]
  def fibs(2), do: [0, 1]

  def fibs(n) when n > 2 do
    last = fibs(n - 1)
    last |> Enum.concat([Enum.sum(Enum.take(last, -2))])
  end

  @doc """
  4. List reversal
  Using the Folder Law:
     "Foldl(list, b, f) <-> Foldr(reverse(list),b, f)"
  """
  def reverse(list) do
    List.foldl(list, [], fn x, acc -> [x | acc] end)
  end

  @doc """
  5. List reversal
    revonto(xs,ys)== reverse(xs)++ys
    1ª lista reversa.append(reverse(2ª lista))
  """
  def revonto([], ys), do: ys
  def revonto([x | xs], ys), do: revonto(xs, [x | ys])

  @doc """
  6. Combinatory
  """
  def pascal(0), do: []
  def pascal(n), do: pascal(n - 1) |> next_row

  defp next_row([]), do: [1]

  defp next_row(row) do
    [0 | row]
    |> Enum.zip(row ++ [0])
    |> Enum.map(&(elem(&1, 0) + elem(&1, 1)))
  end

  def comb(n, m) do
    Sheet2.pascal(n) |> Enum.at(m)
  end

  @doc """
  7. Merge short
  """
  def mergesort([]), do: []

  def mergesort(list) do
    # 1) Dividimos la lista en 2
    {left, right} = Enum.split(list, div(length(list), 2))
    # 2) Utilizamos una función auxiliar recursiva para mergear
    IO.puts("LEFT: #{inspect(left)} || RIGHT: #{inspect(right)}")
    merge(left, right)
  end

  defp merge([], right), do: right
  defp merge(left, []), do: left

  defp merge([lh | lt], [rh | rt]) do
    IO.puts("lh: #{lh} || rh #{rh}")
    IO.puts("-- lt: #{inspect(lt)} || rt #{inspect(rt)}")

    if lh <= rh do
      IO.puts("lh: #{lh} <= rh #{rh}")
      [lh | merge(lt, [rh | rt])]
    else
      [rh | merge([lh | lt], rt)]
    end
  end

  @doc """
  8. Permutations
  """
  def permuts([]), do: [[]]

  def permuts(list) do
    for i <- list, rest <- permuts(list -- [i]), do: [i | rest]
  end

  @doc """
  9. Vectors as lists
  """

  @doc """
  10. Matrices
  """
  def dim([]), do: {0, 0}

  def dim([row | matrix]) do
    {num_rows, num_cols} = dim(matrix)
    {length(matrix) + 1, length(row) || num_cols}
  end

  @doc """
  11. Matrix sum
  """
  def matrixsum(matrix1, matrix2) do
    {num_rows, num_cols} = dim(matrix1)

    if {num_rows, num_cols} == dim(matrix2) do
      Enum.zip(matrix1, matrix2)
      |> Enum.map(fn {row1, row2} -> Enum.zip(row1, row2) |> Enum.map(fn {x, y} -> x + y end) end)
    else
      {:error, "Las dimensiones de las matrices no coinciden"}
    end
  end

  @doc """
  12. Transposition
  """
  def transpose([]), do: []

  def transpose(matrix) do
    [Enum.map(matrix, &hd/1) | transpose(Enum.map(matrix, &tl/1))]
  end

  @doc """
  13. Matrix product
  """
  def matrixprod([], _), do: []
  def matrixprod(_, []), do: []

  def matrixprod(matrix1, matrix2) when length(matrix1) > 0 and length(matrix2) > 0 do
    if length(matrix1[0]) == length(matrix2) do
      [
        for i <- 0..(length(matrix1) - 1) do
          [
            for j <- 0..(length(matrix2[0]) - 1) do
              dot_product(matrix1[i], transpose(matrix2)[j])
            end
          ]
        end
      ]
    else
      {:error, "Invalid matrix dimensions for multiplication"}
    end
  end

  defp dot_product(vec1, vec2) do
    Enum.zip(vec1, vec2) |> Enum.reduce(0, fn {x, y}, acc -> x * y + acc end)
  end

  @doc """
  14. Erathostenes
  """
  def primes_upto(n) when n >= 2 do
    sieve(2..n, [])
  end

  defp sieve([], primes), do: primes

  defp sieve([p | xs], primes) do
    if is_prime(p, primes) do
      sieve(remove_multiples(p, xs), [p | primes])
    else
      sieve(xs, primes)
    end
  end

  defp remove_multiples(p, xs) do
    Enum.reject(xs, fn x -> rem(x, p) == 0 end)
  end

  defp is_prime(n, primes) do
    for p <- primes, p <= trunc(:math.sqrt(n)), rem(n, p) == 0 do
      false
    end
    true
  end

  @doc """
  15. Factorization
  """
  def factorize(n) do
    factorize(n, 2, [])
  end

  defp factorize(1, _, factors) do
    factors
  end

  defp factorize(n, divisor, factors) when rem(n, divisor) == 0 do
    factorize(div(n, divisor), divisor, [divisor | factors])
  end

  defp factorize(n, divisor, factors) do
    factorize(n, divisor + 1, factors)
  end
end
