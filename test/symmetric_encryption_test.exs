defmodule SymmetricEncryptionTest do
  use ExUnit.Case
#  doctest SymmetricEncryption

  test "encrypts and decrypts" do
    encrypted = SymmetricEncryption.encrypt("Hello World")
    decrypted = SymmetricEncryption.decrypt(encrypted)
    assert decrypted == "Hello World"
  end
end
