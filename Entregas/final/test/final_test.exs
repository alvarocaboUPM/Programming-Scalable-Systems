defmodule FinalTest do
  use ExUnit.Case
  doctest Final

  describe "create_bank/0" do
    test "returns a pid" do
      bank = Final.Bank.create_bank()
      assert is_pid(bank)
    end
  end

  describe "new_account/2" do
    test "creates a new account with zero balance" do
      bank = Final.Bank.create_bank()
      assert Final.Bank.new_account(bank, "account1")
      assert Final.Bank.new_account(bank, "account2")
      assert Final.Bank.balance(bank, "account1") == 0
      assert Final.Bank.balance(bank, "account2") == 0
    end

    test "returns false if the account already exists" do
      bank = Final.Bank.create_bank()
      assert Final.Bank.new_account(bank, "account1")
      assert !Final.Bank.new_account(bank, "account1")
    end
  end

  describe "deposit/3" do
    test "increases account balance" do
      bank = Final.Bank.create_bank()
      Final.Bank.new_account(bank, "account1")
      assert Final.Bank.deposit(bank, "account1", 100) == 100
      assert Final.Bank.balance(bank, "account1") == 100
    end
  end

  describe "withdraw/3" do
    test "decreases account balance if sufficient balance is available" do
      bank = Final.Bank.create_bank()
      Final.Bank.new_account(bank, "account1")
      Final.Bank.deposit(bank, "account1", 100)
      assert Final.Bank.withdraw(bank, "account1", 50) == 50
      assert Final.Bank.balance(bank, "account1") == 50
    end

    test "returns 0 and does not change balance if insufficient balance is available" do
      bank = Final.Bank.create_bank()
      Final.Bank.new_account(bank, "account1")
      Final.Bank.deposit(bank, "account1", 100)
      assert Final.Bank.withdraw(bank, "account1", 150) == 0
      assert Final.Bank.balance(bank, "account1") == 100
    end
  end

  describe "transfer/4" do
    test "transfers money from one account to another" do
      bank = Final.Bank.create_bank()
      Final.Bank.new_account(bank, "account1")
      Final.Bank.new_account(bank, "account2")
      Final.Bank.deposit(bank, "account1", 100)
      assert Final.Bank.transfer(bank, "account1", "account2", 50) == 50
      assert Final.Bank.balance(bank, "account1") == 50
      assert Final.Bank.balance(bank, "account2") == 50
    end

    test "returns 0 and does not change balance if insufficient balance is available" do
      bank = Final.Bank.create_bank()
      Final.Bank.new_account(bank, "account1")
      Final.Bank.new_account(bank, "account2")
      Final.Bank.deposit(bank, "account1", 100)
      assert Final.Bank.transfer(bank, "account1", "account2", 150) == 0
      assert Final.Bank.balance(bank, "account1") == 100
      assert Final.Bank.balance(bank, "account2") == 0
    end
  end

  describe "balance/2" do
    test "returns the current balance for the account" do
      bank = Final.Bank.create_bank()
      Final.Bank.new_account(bank, "account1")
      Final.Bank.deposit(bank, "account1", 100)
      assert Final.Bank.balance(bank, "account1") == 100
    end
  end
end
