defmodule Lesson5 do
  @moduledoc """
  Documentation for `Lesson5`.
  """

  @doc """
    Foldr pattern -> foldr([x1, x2, x3], b, op) = op(x1, op(x2, op(x3, b)))
    - Fold right -> En lugar de reducir cambiado los cons (|) por operandos hasta
    llegar a la [], se acumula
  """
  def foldr(list, acc, fun) do
    Enum.reverse(list)
    |> Enum.reduce(acc, fun)
  end

  @doc """
    Mapping(List, fun) -> Devuelve la lista con la función aplicada a todos
    los miembros de la lista
  """
  def mapping(list, fun) do

  end

  @doc """
   Zipping(list, list) -> Combina 2 listas de la misma longitud
  """

end
