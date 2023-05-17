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
    fibs(n, [1, 0])
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
    @doc """
    Creates a new bank server process and returns its pid.
    """
    def create_bank() do
      spawn(fn -> bankserver(%{}) end)
    end

    @doc """
    Adds a new account to the bank.
    Returns `true` if the account was successfully added, `false` otherwise.
    """
    @spec new_account(bank :: pid(), account :: String.t()) :: boolean()
    def new_account(bank, account) do
      send(bank, {:new_account, self(), account})
      receive do
        :ok -> true
        _ -> false
      end
    end

    @doc """
    Withdraws `quantity` from `from_account` in the bank.
    Returns `{:ok, new_balance}` if the withdrawal was successful, where `new_balance` is the
    new balance of the account.
    Returns `{:error, reason}` if the withdrawal failed, where `reason` is an error message.
    """
    @spec withdraw(bank :: pid(), from_account :: String.t(), quantity :: number()) ::
            {:ok, number()} | {:error, String.t()}
    def withdraw(bank, from_account, quantity) do
      send(bank, {:withdraw, self(), from_account, quantity})
      receive do
        {:ok, amount} -> amount
        {:error, msg} -> msg
      end
    end

    @doc """
    Deposits `quantity` into `from_account` in the bank.
    Returns `new_balance` if the deposit was successful, where `new_balance` is the
    new balance of the account.
    Returns `{:error, reason}` if the deposit failed, where `reason` is an error message.
    """
    @spec deposit(bank :: pid(), from_account :: String.t(), quantity :: number()) ::
            number()| {:error, String.t()}
    def deposit(bank, from_account, quantity) do
      send(bank, {:deposit, self(), from_account, quantity})
      receive do
        {:ok, amount} -> amount
        {:error, msg} -> msg
      end
    end

    @doc """
    Deposits `quantity` into `from_account` in the bank.
    Returns `balance` if the account was found.
    Returns `{:error, reason}` if the deposit failed, where `reason` is an error message.
    """
    @spec balance(bank :: pid(), account :: String.t()) ::
            {:ok, number()} | {:error, String.t()}
    def balance(bank, account) do
      send(bank, {:balance, self(), account})
      receive do
        {:ok, balance} -> balance
        {:error, msg} -> msg
      end

    end

    @doc """
    Transfers `quantity` from `from_account` to `to_account` in the bank.
    Returns `{:ok, new_balance}` if the transfer was successful, where `new_balance` is the
    new balance of `from_account`.
    Returns `{:error, reason}` if the transfer failed, where `reason` is an error message.
    """
    @spec transfer(
            bank :: pid(),
            from_account :: String.t(),
            to_account :: String.t(),
            quantity :: number()
          ) :: {:ok, number()} | {:error, String.t()}
    def transfer(bank, from_account, to_account, quantity) do
      send(bank, {:transfer, self(), from_account, to_account, quantity})
      receive do
        {:ok, amount} -> amount
        {:error, msg} -> msg
      end
    end

    @doc """
    Implementation details of the bank server process.
    """
    @spec bankserver(map()) :: :ok
    def bankserver(accounts) do
      receive do
        {:new_account, from_pid, account, } ->
          case Map.has_key?(accounts, account) do
            true ->
              send(from_pid, {:err, false})
              bankserver(accounts)
            false ->
              send(from_pid, :ok)
              bankserver(Map.put(accounts, account, 0))
          end


        {:withdraw, from_pid, account, amount} ->
          case Map.get(accounts, account) do
            nil ->
              send(from_pid, {:error, "Account not found"})

            balance when balance >= amount ->
              new_balance = balance - amount
              Map.put(accounts, account, new_balance)
              send(from_pid, {:ok, new_balance})

            _ ->
              send(from_pid, {:error, "insufficient funds"})
              bankserver(accounts)
          end

        {:deposit, from_pid, account,  amount} ->
          case Map.get(accounts, account) do
            nil ->
              send(from_pid, {:error, "Account not found"})
              bankserver(accounts)

            _ ->
              updated_accounts =
                Map.update(accounts, account, account, fn balance -> balance + amount end)

              send(from_pid, {:ok, amount})
              bankserver(updated_accounts)
          end

          {:balance, from_pid, account } ->
            case Map.get(accounts, account) do
              nil ->
                send(from_pid, {:error, "Account not found"})
                bankserver(accounts)

              balance ->
                send(from_pid, {:ok, balance})
                bankserver(accounts)
            end

        {:transfer, from_pid,account_from, account_to,  amount} ->
          case Map.get(accounts, account_from) do
            nil ->
              send(from_pid, {:error, "Account 1 not found"})
              bankserver(accounts)

            balance when balance >= amount ->
              case Map.get(accounts, account_to) do
                nil ->
                  send(from_pid, {:error, "Account 2 not found"})
                  bankserver(accounts)

                _ ->
                  updated_from =
                    Map.update(accounts, account_from, account_from, fn balance ->
                      balance - amount
                    end)

                  updated_to =
                    Map.update(updated_from, account_to, account_from, fn balance ->
                      balance + amount
                    end)

                  send(from_pid, {:ok, amount})
                  bankserver(updated_to)
              end

            _ ->
              send(from_pid, {:error, "Insufficient balance"})
              bankserver(accounts)
          end
      end
    end

    # @spec send_and_receive(pid(), term()) :: term()
    # defp send_and_receive(server_pid, message) do
    #   response_pid=self()
    #   # Send the message to the server
    #   send(server_pid, message)

    #   # Wait for a response from the server
    #   receive do
    #     {^response_pid, response} ->
    #       response

    #     {_, _} ->
    #       # Ignore any unexpected messages and try again
    #       send(server_pid, message)
    #   end
    # end

  end

  defmodule OTPBank do
    use GenServer

    @doc """
    Creates a new bank server process and returns its pid.
    """
    def create_bank() do
      {:ok, bank} = GenServer.start_link(__MODULE__, %{}, name: OPTBank)
      bank
    end

    @doc """
    Adds a new account to the bank.
    Returns true if the account was successfully added, false otherwise.
    """
    @spec new_account(bank :: pid(), account :: String.t()) :: true | false
    def new_account(bank, account) do
      GenServer.call(bank, {:new_account, account})
    end

    @doc """
    Withdraws `quantity` from `from_account` in the bank.
    Returns `{:ok, new_balance}` if the withdrawal was successful, where `new_balance` is the
    new balance of the account.
    Returns `{:error, reason}` if the withdrawal failed, where `reason` is an error message.
    """
    @spec withdraw(bank :: pid(), from_account :: String.t(), quantity :: number()) ::
            {:ok, number()} | {:error, String.t()}
    def withdraw(bank, from_account, quantity) do
      {:ok, balance} = GenServer.call(bank, {:withdraw, from_account, quantity})
      balance
    end

    @doc """
    Deposits `quantity` into `from_account` in the bank.
    Returns `{:ok, new_balance}` if the deposit was successful, where `new_balance` is the
    new balance of the account.
    Returns `{:error, reason}` if the deposit failed, where `reason` is an error message.
    """
    @spec deposit(bank :: pid(), from_account :: String.t(), quantity :: number()) ::
            {:ok, number()} | {:error, String.t()}
    def deposit(bank, from_account, quantity) do
      {:ok, balance} = GenServer.call(bank, {:deposit, from_account, quantity})
      balance
    end

    @doc """
    Transfers `quantity` from `from_account` to `to_account` in the bank.
    Returns `{:ok, new_balance}` if the transfer was successful, where `new_balance` is the
    new balance of `from_account`.
    Returns `{:error, reason}` if the transfer failed, where `reason` is an error message.
    """
    @spec transfer(
            bank :: pid(),
            from_account :: String.t(),
            to_account :: String.t(),
            quantity :: number()
          ) :: {:ok, number()} | {:error, String.t()}
    def transfer(bank, from_account, to_account, quantity) do
      {:ok, balance} = GenServer.call(bank, {:transfer, from_account, to_account, quantity})
      balance
    end

    @doc """
    Returns the current balance for the account
    """
    @spec balance(
            bank :: pid(),
            account :: String.t()
          ) :: number() | {:error, String.t()}
    def balance(bank, account) do
      {:ok, balance} = GenServer.call(bank, {:balance, account})
      balance
    end

    ## GenServer callbacks

    @impl GenServer
    def init(_) do
      {:ok, %{}}
    end

    @impl GenServer
    def handle_call({:withdraw, account, amount}, _from, state) do
      case Map.get(state, account) do
        nil ->
          {:reply, {:ok, "Account not found"}, state}

        balance when balance >= amount ->
          new_balance = balance - amount
          updated_state = Map.put(state, account, new_balance)
          {:reply, {:ok, new_balance}, updated_state}

        _ ->
          {:reply, {:error, "Insufficient funds"}, state}
      end
    end

    @impl GenServer
    def handle_call({:deposit, account, amount}, _from, state) do
      case Map.get(state, account) do
        nil ->
          {:reply, {:error, "Account not found"}, state}

        balance ->
          new_balance = balance + amount
          updated_state = Map.put(state, account, new_balance)
          {:reply, {:ok, new_balance}, updated_state}
      end
    end

    @impl GenServer
    def handle_call({:new_account, account}, _from, accounts) do
      case Map.has_key?(accounts, account) do
        true ->
          {:reply, false, accounts}

        false ->
          {:reply, true, Map.put(accounts, account, 0)}
      end
    end

    @impl GenServer
    def handle_call({:balance, account}, _from, state) do
      case Map.get(state, account) do
        nil ->
          {:reply, {:error, "Account not found"}, state}

        balance ->
          {:reply, balance, state}
      end
    end

    @impl GenServer
    def handle_call({:transfer, from_account, to_account, quantity}, _from, accounts) do
      case Map.has_key?(accounts, from_account) do
        false ->
          {:reply, {:error, "Account not found"}, accounts}

        true ->
          case Map.has_key?(accounts, to_account) do
            false ->
              {:reply, {:error, "Account not found"}, accounts}

            true ->
              case Map.get(accounts, from_account) do
                balance when balance >= quantity ->
                  new_from_balance = balance - quantity
                  new_to_balance = Map.get(accounts, to_account) + quantity

                  new_accounts =
                    accounts
                    |> Map.put(from_account, new_from_balance)
                    |> Map.put(to_account, new_to_balance)

                  {:reply, {:ok, new_from_balance}, new_accounts}

                _ ->
                  {:reply, {:error, "Insufficient funds"}, accounts}
              end
          end
      end
    end
  end
end
