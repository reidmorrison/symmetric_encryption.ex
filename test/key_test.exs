defmodule KeyTest do
  use ExUnit.Case
  doctest SymmetricEncryption.Key

  test "no key or iv when initially created" do
    assert %{ key: nil, iv: nil} = %SymmetricEncryption.Key{}
  end

  test "random_key" do
    key = SymmetricEncryption.Key.random_key()
    assert byte_size(key.key()) == 32
    assert key.iv() == nil
  end

  test "random_iv" do
    key = SymmetricEncryption.Key.random_iv()
    assert byte_size(key.iv()) == 16
    assert key.key() == nil
  end
end
