defmodule FinalTest do
  use ExUnit.Case
  doctest Final

  @bank %{}

  describe "create_bank" do
    test "creates a bank process and returns a PID" do
      pid = Final.Bank.create_bank()
      assert is_pid(pid)
    end
  end

  describe "new_account" do
    setup do
      bank = %{"account1" => 0}
      {:ok, bank: bank}
    end

    test "creates a new account" do
      assert Final.Bank.new_account(@bank, "account2")
      assert Map.has_key?(@bank, "account2")
    end

    test "fails to create an existing account" do
      refute Final.Bank.new_account(@bank, "account1")
    end
  end

  describe "withdraw" do
    setup do
      bank = %{"account1" => 100}
      {:ok, bank: bank}
    end

    test "withdraws money if there are sufficient funds" do
      assert {:ok, 50} = Final.Bank.withdraw(@bank, "account1", 50)
      assert 50 == Map.get(@bank, "account1")
    end

    test "fails to withdraw money if there are insufficient funds" do
      assert {:error, "insufficient funds"} = Final.Bank.withdraw(@bank, "account1", 200)
      assert 100 == Map.get(@bank, "account1")
    end

    test "fails to withdraw money from a non-existent account" do
      assert {:error, "account does not exist"} = Final.Bank.withdraw(@bank, "account2", 50)
    end
  end

  describe "deposit" do
    setup do
      bank = %{"account1" => 100}
      {:ok, bank: bank}
    end

    test "deposits money into an existing account" do
      assert {:ok, 150} = Final.Bank.deposit(@bank, "account1", 50)
      assert 150 == Map.get(@bank, "account1")
    end

    test "fails to deposit money into a non-existent account" do
      assert {:error, "account does not exist"} = Final.Bank.deposit(@bank, "account2", 50)
    end
  end

  describe "transfer" do
    setup do
      bank = %{"account1" => 100, "account2" => 0}
      {:ok, bank: bank}
    end

    test "transfers money between existing accounts" do
      assert {:ok, 50} = Final.Bank.transfer(@bank, "account1", "account2", 50)
      assert 50 == Map.get(@bank, "account1")
      assert 50 == Map.get(@bank, "account2")
    end

    test "fails to transfer money if there are insufficient funds" do
      assert {:error, "insufficient funds"} = Final.Bank.transfer(@bank, "account1", "account2", 200)
      assert 100 == Map.get(@bank, "account1")
      assert 0 == Map.get(@bank, "account2")
    end

    test "fails to transfer money from a non-existent account" do
      assert {:error, "account does not exist"} = Final.Bank.transfer(@bank, "account3", "account2", 50)
    end

    test "fails to transfer money to a non-existent account" do
      assert {:error, "account does not exist"} = Final.Bank.transfer(@bank, "account1", "account3", 20)
    end
  end

  describe "balance/2" do
    test "returns the account balance when the account exists" do
      bank = %{"account1" => 100, "account2" => 200}
      assert {:ok, 100} == Final.Bank.balance(bank, "account1")
    end

    test "returns an error when the account does not exist" do
      bank = %{"account1" => 100, "account2" => 200}
      assert {:error, "account does not exist"} == Final.Bank.balance(bank, "account3")
    end
  end
end
