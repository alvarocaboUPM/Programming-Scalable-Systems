defmodule Final do
  @moduledoc """
  Entrega final evaluable
  """

  def date_parts(date_str) do
    String.split(date_str, "-")
    |> Enum.map(&String.to_integer/1)
  end

  @spec fibs(pos_integer()) :: [pos_integer()]
  def fibs(n) when n >= 0 do
    fibs(n, [1,0])
  end

  defp fibs(0, _), do: [0]

  defp fibs(1, fib_list) do
    Enum.reverse(fib_list)
  end

  defp fibs(n, [fib_n_minus_1, fib_n_minus_2 | fib_list]) do
    fib_n = fib_n_minus_1 + fib_n_minus_2
    fibs(n - 1, [fib_n, fib_n_minus_1, fib_n_minus_2 | fib_list])
  end

  @spec map([a], (a -> b)) :: [b] when a: any(), b: any()
  def map([], _func), do: []

  def map([h | t], func) do
    [func.(h) | map(t, func)]
  end

  @spec reduce(list :: [a], acc :: b, func :: (a, b -> b)) :: b when a: any(), b: any()
  def reduce([], acc, _func), do: acc

  def reduce([h | t], acc, func) do
    acc = func.(h, acc)
    reduce(t, acc, func)
  end

  @spec filter(list :: [a], func :: (a -> boolean())) :: [a] when a: any()
  def filter([], _func), do: []

  def filter([h | t], func) do
    res = func.(h)

    if res == true do
      [h | filter(t, func)]
    else
      filter(t, func)
    end
  end

  defmodule Bank do
    @moduledoc """
    Simple bank application - non concurrent
    """

    @doc """
    Creates a bank process and returns a "bank" pid
    """
    def create_bank() do
      pid= spawn(fn -> bankserver(%{}) end)
      {:ok, pid}
    end

    @doc """
    Creates a new account with account balance 0. Returns true if the
    account could be created (it was new) and false otherwise.
    """
    @spec new_account(bank :: pid(), account :: String.t()) :: boolean()
    def new_account(bank, account) do
      case Map.has_key?(bank, account) do
        true ->
          false

        false ->
          Map.put(bank, account, 0)
          true
      end
    end

    @doc """
    Withdraws money from the account (if quantity <= account balance).
    Returns the amount of money withdrawn.
    """
    @spec withdraw(bank :: pid(), from_account :: String.t(), quantity :: number()) :: {:ok, number()} | {:error, String.t()}
    def withdraw(bank, account, quantity) do
      case Map.get(bank, account) do
        nil ->
          {:error, "account does not exist"}

        balance when balance >= quantity ->
          new_balance = balance - quantity
          Map.put(bank, account, new_balance)
          {:ok, quantity}

        _ ->
          {:error, "insufficient funds"}
      end
    end

    @doc """
    Increases balance of account by quantity, returning the new balance.
    """
    @spec deposit(bank :: pid(), from_account :: String.t(), quantity :: number()) :: {:ok, number()} | {:error, String.t()}
    def deposit(bank, account, quantity) do
      case Map.get(bank, account) do
        nil ->
          {:error, "account does not exist"}

        balance ->
          new_balance = balance + quantity
          Map.put(bank, account, new_balance)
          {:ok, new_balance}
      end
    end

    @doc """
    Transfers quantity from one account (if the balance is sufficient)
    to another account. Returns the amount of money transferred.
    """
    @spec transfer(bank :: pid(), from_account :: String.t(), to_account :: String.t(), quantity :: number()) :: {:ok, number()} | {:error, String.t()}
    def transfer(bank, from_account, to_account, quantity) do
      case withdraw(bank, from_account, quantity) do
        {:ok, withdrawn} ->
          case deposit(bank, to_account, withdrawn) do
            {:ok, deposited} ->
              {:ok, deposited}

            {:error, reason} ->
              deposit(bank, from_account, withdrawn)
              {:error, reason}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end

    @doc """
    Returns the current balance for the account
    """
    def balance(bank, account) do
      case Map.get(bank, account) do
        nil -> {:error, "account does not exist"}
        balance -> {:ok, balance}
      end
    end

    # Servidor

    @spec bankserver(map()) :: :ok
    def bankserver(bank) do
      receive do
        {:new_account, from, account} ->
          case Map.has_key?(bank, account) do
            true ->
              send(from, {:error, "account already exists"})
              bankserver(bank)

            false ->
              send(from, :ok)
              bankserver(Map.put(bank, account, 0))
          end

        {:withdraw, from, account, quantity} ->
          case Map.get(bank, account) do
            nil ->
              send(from, {:error, "account does not exist"})
              bankserver(bank)

            balance when balance >= quantity ->
              new_balance = balance - quantity
              send(from, {:ok, quantity})
              bankserver(Map.put(bank, account, new_balance))

            _ ->
              send(from, {:error, "insufficient funds"})
              bankserver(bank)
          end

        {:deposit, from, account, quantity} ->
          case Map.get(bank, account) do
            nil ->
              send(from, {:error, "account does not exist"})
              bankserver(bank)

            balance ->
              new_balance = balance + quantity
              send(from, {:ok, new_balance})
              bankserver(Map.put(bank, account, new_balance))
          end

        {:transfer, from, from_account, to_account, quantity} ->
          case Map.get(bank, from_account) do
            nil ->
              send(from, {:error, "from account does not exist"})
              bankserver(bank)

            balance when balance >= quantity ->
              case Map.get(bank, to_account) do
                nil ->
                  send(from, {:error, "to account does not exist"})
                  bankserver(bank)

                _ ->
                  new_from_balance = balance - quantity
                  new_to_balance = Map.get(bank, to_account) + quantity
                  send(from, {:ok, quantity})
                  bankserver(Map.put(Map.put(bank, from_account, new_from_balance), to_account, new_to_balance))
              end

            _ ->
              send(from, {:error, "insufficient funds"})
              bankserver(bank)
          end

        {:balance, from, account} ->
          case Map.get(bank, account) do
            nil ->
              send(from, {:error, "account does not exist"})
              bankserver(bank)

            balance ->
              send(from, {:ok, balance})
              bankserver(bank)
          end

        {:stop, from} ->
          send(from, :ok)
        end
    end
    end
end

defmodule OTPBank do
  use GenServer
  # Cliente
  def create_bank() do
    GenServer.start(__MODULE__, %{})
  end

  #GenServer.call -> Llamda síncrona
  #GenServer.cast -> Llamda asíncrona

  # Servidor (Cambiar lista por mapa)
  def init(%{}) do
    {:ok, %{}}
  end

  def handle_call(:balance, _state) do

  end

  def handle_cast({:new_account, account}, state) do
    {:noreply, [account | state]}
  end


end
