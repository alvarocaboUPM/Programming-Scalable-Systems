defmodule FinalTest do
  use ExUnit.Case
  doctest Final

  test "bank_0" do
    bank = Final.Bank.create_bank()
    assert Final.Bank.new_account(bank,1) == true
    assert Final.Bank.new_account(bank,1) == false
    assert Final.Bank.balance(bank,1) == 0
    assert Final.Bank.deposit(bank,1,10) == 10
    assert Final.Bank.new_account(bank,2) == true
    assert Final.Bank.balance(bank,2) == 0
    assert Final.Bank.transfer(bank,1,2,5) == 5
    assert Final.Bank.balance(bank,1) == 5
    assert Final.Bank.balance(bank,2) == 5
    assert Final.Bank.withdraw(bank,2,3) == 3
    assert Final.Bank.balance(bank,2) == 2
  end

  test "OPTbank_1" do
    bank = Final.OTPBank.create_bank()
    assert Final.OTPBank.new_account(bank,1) == true
    assert Final.OTPBank.new_account(bank,1) == false
    assert Final.OTPBank.balance(bank,1) == 0
    assert Final.OTPBank.deposit(bank,1,10) == 10
    assert Final.OTPBank.new_account(bank,2) == true
    assert Final.OTPBank.balance(bank,2) == 0
    assert Final.OTPBank.transfer(bank,1,2,5) == 5
    assert Final.OTPBank.balance(bank,1) == 5
    assert Final.OTPBank.balance(bank,2) == 5
    assert Final.OTPBank.withdraw(bank,2,3) == 2
    assert Final.OTPBank.balance(bank,2) == 2
  end
end
