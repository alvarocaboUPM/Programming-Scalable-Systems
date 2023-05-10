defmodule Final do
  @moduledoc """
  Entrega final evaluable
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

  @spec map([a], (a -> b)) :: [b] when a: any(), b: any()
  def map([], _func), do: []

  def map([h|t], func) do
    [func.(h) | map(t, func)]
  end

  @spec reduce(list :: [a], acc :: b, func :: (a, b -> b)) :: b when a: any(), b: any()
  def reduce([], acc, _func), do: acc

  def reduce([h|t], acc, func) do
    acc= func.(h,acc)
    reduce(t, acc, func)
  end

  @spec filter(list :: [a], func :: (a -> boolean())) :: [a] when a: any()
  def filter([], _func), do: []

  def filter([h|t], func) do
    res = func.(h)
    if res == true do
      [h | filter(t, func)]
    else
      filter(t, func)
    end
  end

  defmodule Bank do
    #  Creates a bank and returns a "bank" pid
    def create_bank() do
      spawn(fn -> loop(%{accounts: %{}, next_account_id: 1}) end)
    end

    defp loop(state) do
      receive do
        {:new_account, from, account} ->
          new_state = new_account(pid_to_state(state), account)
          send(from, {:ok, state_to_pid(new_state)})
          loop(state)

        {:withdraw, from, account_id, amount} ->
          new_state = withdraw(pid_to_state(state), account_id, amount)
          send(from, {:ok, state_to_pid(new_state)})
          loop(state)

        {:deposit, from, account_id, amount} ->
          new_state = deposit(pid_to_state(state), account_id, amount)
          send(from, {:ok, state_to_pid(new_state)})
          loop(state)

        {:transfer, from, account_id_from, account_id_to, amount} ->
          new_state = transfer(pid_to_state(state), account_id_from, account_id_to, amount)
          send(from, {:ok, state_to_pid(new_state)})
          loop(state)

        {:balance, from, account_id} ->
          send(from, {:ok, balance(pid_to_state(state), account_id)})
          loop(state)
      end
    end

    defp pid_to_state(pid) do
      :sys.get_state(pid)
    end

    defp state_to_pid(state) do
      # Use :erlang.term_to_binary to convert the state to a binary,
      # and then spawn a new process that loads the binary into its state.
      binary_state = state_to_binary(state)

      spawn(fn ->
        :sys.replace_state(self(), :erlang.binary_to_term(binary_state))
        loop(:sys.get_state(self()))
      end)
    end

    defp state_to_binary(state) do
      # Use :erlang.term_to_binary to convert the state to a binary.
      :erlang.term_to_binary(state)
    end

    # Creates a new account with account balance 0. Returns true if the
    # account could be created (it was new) and false otherwise.
    def new_account(bank_pid, account) do
      case :sys.get_state(bank_pid) do
        %{accounts: accounts} ->
          case Map.get(accounts, account) do
            nil ->
              new_accounts = Map.put(accounts, account, 0)
              :sys.replace_state(bank_pid, %{accounts: new_accounts})
              {:ok, true}

            _ ->
              {:ok, false}
          end

        _ ->
          {:error, "Bank not found"}
      end
    end

    # Withdraws money from the account (if quantity =< account balance).
    # Returns the amount of money withdrawn.
    def withdraw(bank_pid, account, quantity) do
      case :sys.get_state(bank_pid) do
        %{accounts: accounts} ->
          case Map.get(accounts, account) do
            nil ->
              {:error, "Account not found"}

            balance ->
              if balance >= quantity do
                new_balance = balance - quantity
                new_accounts = Map.put(accounts, account, new_balance)
                :sys.replace_state(bank_pid, %{accounts: new_accounts})
                {:ok, new_balance}
              else
                {:error, "Insufficient funds"}
              end
          end

        _ ->
          {:error, "Invalid bank PID"}
      end
    end

    # Increases balance of account by quantity, returning the new balance.
    def deposit(bank_pid, account, quantity) do
      case :sys.get_state(bank_pid) do
        %{accounts: accounts} ->
          case Map.get(accounts, account) do
            nil ->
              {:error, "Account not found"}

            balance ->
              new_balance = balance + quantity
              new_accounts = Map.put(accounts, account, new_balance)
              :sys.replace_state(bank_pid, %{accounts: new_accounts})
              {:ok, new_balance}
          end

        _ ->
          {:error, "Invalid bank PID"}
      end
    end

    # Transfers quantity from one account (if the balance is sufficient)
    # to another account. Returns the amount of money transferred.
    def transfer(bank_pid, from_account, to_account, quantity) do
      case withdraw(bank_pid, from_account, quantity) do
        {:ok, amount} ->
          case deposit(bank_pid, to_account, amount) do
            {:ok, new_balance} ->
              {:ok, amount}

            error ->
              error
          end

        error ->
          error
      end
    end

    # Returns the current balance for the account
    def balance(bank_pid, account) do
      case :sys.get_state(bank_pid) do
        %{accounts: accounts} ->
          case Map.get(accounts, account) do
            nil -> {:error, "Account not found"}
            balance -> {:ok, balance}
          end

        _ ->
          {:error, "Invalid bank PID"}
      end
    end
  end
end
