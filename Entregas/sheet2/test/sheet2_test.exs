defmodule Sheet2Test do
  use ExUnit.Case

  test "fib_1", do: assert(Sheet2.fib(1) == 1)
  test "fib_2", do: assert(Sheet2.fib(2) == 1)
  test "fib_6", do: assert(Sheet2.fib(6) == 8)

  test "gcd_28_0", do: assert(Sheet2.gcd(28, 0) == 28)
  test "gcd_1071_462", do: assert(Sheet2.gcd(1071, 462) == 21)

  test "reverse_1", do: assert(Sheet2.reverse([1, 2, 3]) == [3, 2, 1])
  test "reverse_2", do: assert(Sheet2.reverse([1, 2, 3, 2, 2]) == [2, 2, 3, 2, 1])

  test "revonto_1",
    do: assert(Sheet2.revonto([1, 2, 3], [4, 5]) == Sheet2.reverse([1, 2, 3]) ++ [4, 5])

  test "pascal_0", do: assert(Sheet2.pascal(0) == [1])
  test "pascal_1", do: assert(Sheet2.pascal(1) == [1, 1])
  test "pascal_2", do: assert(Sheet2.pascal(2) == [1, 2, 1])
  test "pascal_3", do: assert(Sheet2.pascal(3) == [1, 3, 3, 1])
  test "pascal_4", do: assert(Sheet2.pascal(4) == [1, 4, 6, 4, 1])

  test "mergesort_1", do: assert(Sheet2.mergesort([1, 3, 2]) == [1, 2, 3])
  test "mergesort_2", do: assert(Sheet2.mergesort([]) == [])
  test "mergesort_3", do: assert(Sheet2.mergesort([3, 2, 1]) == [1, 2, 3])
  test "mergesort_4", do: assert(Sheet2.mergesort([1, 3, 1, 2, 1, 4, 4]) == [1, 1, 1, 2, 3, 4, 4])

  test "permuts_1", do: assert(Sheet2.permuts([]) == [])
  test "permuts_2", do: assert(Sheet2.permuts([1]) == [[1]])
  test "permuts_3", do: assert(Sheet2.permuts([1, 2]) == [[1, 2], [2, 1]])

  test "permuts_4",
    do:
      assert(
        MapSet.equal?(
          MapSet.new(Sheet2.permuts([1, 2, 3])),
          MapSet.new([[1, 2, 3], [3, 2, 1], [1, 3, 2], [3, 1, 2], [2, 1, 3], [2, 3, 1]])
        )
      )

  # Testing for equality on floating point numbers is dangerous...
  test "vadd_1", do: assert(Sheet2.vadd([1.0, 2.0, 3.0], [2.0, 3.0, 4.0]) == [3.0, 5.0, 7.0])
  test "scale_1", do: assert(Sheet2.scale([1.0, 2.0, 3.0], 2) == [2.0, 4.0, 6.0])

  test "dotprod_1",
    do: assert(Sheet2.dotprod([1.0, 2.0, 3.0], [2.0, 3.0, 4.0]) == Enum.sum([2.0, 6.0, 12.0]))

  test "primes_1", do: assert(Sheet2.primes_upto(2) == [2])
  test "primes_2", do: assert(Sheet2.primes_upto(3) == [2, 3])
  test "primes_3", do: assert(Sheet2.primes_upto(20) == [2, 3, 5, 7, 11, 13, 17, 19])

  test "factorize_1", do: assert(Enum.sort(Sheet2.factorize(20)) == [2, 2, 5])
  test "factorize_2", do: assert(Enum.sort(Sheet2.factorize(17)) == [17])
  test "factorize_3", do: assert(Enum.sort(Sheet2.factorize(135)) == [3, 3, 3, 5])

  test "tree_insert0" do
    assert Sheet2.tree_insert(:tip, 10) == {:node, :tip, 10, :tip}
  end

  test "tree_insert1" do
    assert Sheet2.tree_insert(one_tree(), 10) ==
             {:node, {:node, :tip, 1, :tip}, 5,
              {:node, {:node, :tip, 7, {:node, :tip, 10, :tip}}, 15, {:node, :tip, 20, :tip}}}
  end

  defp one_tree() do
    {:node, {:node, :tip, 1, :tip}, 5,
     {:node, {:node, :tip, 7, :tip}, 15, {:node, :tip, 20, :tip}}}
  end

  test "tree_inorder0" do
    assert Sheet2.inorder(:tip) == []
  end

  test "tree_inorder1" do
    tree = one_tree()
    assert Sheet2.inorder(tree) == [1, 5, 7, 15, 20]
  end

  # Missing tests for matrix sum, transposition, matrix product
end
