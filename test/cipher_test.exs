defmodule CipherTest do
  use ExUnit.Case
  doctest SymmetricEncryption.Cipher

  test "no key or iv when initially created" do
    assert %{ key: nil, iv: nil, version: 1} = %SymmetricEncryption.Cipher{}
  end

  test "randomize" do
    cipher = SymmetricEncryption.Cipher.randomize()
    assert byte_size(cipher.key) == 32
    assert byte_size(cipher.iv) == 16
  end

  test "random_key" do
    cipher = SymmetricEncryption.Cipher.random_key()
    assert byte_size(cipher.key) == 32
    assert cipher.iv == nil
  end

  test "random_iv" do
    cipher = SymmetricEncryption.Cipher.random_iv()
    assert byte_size(cipher.iv) == 16
    assert cipher.key == nil
  end
end
