defmodule EncryptorTest do
  use ExUnit.Case
  doctest SymmetricEncryption.Encryptor

  @long_string "This is a really long string for testing compression that needs to span more than one AES block."
  @long_long_string @long_string <> @long_string

  test "encrypts" do
    encrypted = SymmetricEncryption.Encryptor.encrypt("Hello World")
    assert byte_size(encrypted) == 56
  end

  test "compresses" do
    not_compressed = SymmetricEncryption.Encryptor.encrypt(@long_long_string, compress: false)
    compressed = SymmetricEncryption.Encryptor.encrypt(@long_long_string, compress: true)
    assert byte_size(not_compressed) > byte_size(compressed)
  end

  test "does not compress small data" do
    not_compressed = SymmetricEncryption.Encryptor.encrypt("Hello", compress: false, random_iv: false)
    compressed = SymmetricEncryption.Encryptor.encrypt("Hello", compress: true, random_iv: false)
    assert not_compressed == compressed
  end

  test "creates new iv when not supplied" do
    encrypted1 = SymmetricEncryption.Encryptor.encrypt("Hello World")
    encrypted2 = SymmetricEncryption.Encryptor.encrypt("Hello World")
    assert encrypted1 != encrypted2
  end

  test "fixed encryption with same IV and no compression" do
    encrypted1 = SymmetricEncryption.Encryptor.fixed_encrypt("Hello World")
    encrypted2 = SymmetricEncryption.Encryptor.fixed_encrypt("Hello World")
    assert encrypted1 == encrypted2
  end

  test "fixed encryption with same IV and no compression for large strings" do
    encrypted1 = SymmetricEncryption.Encryptor.fixed_encrypt(@long_long_string)
    encrypted2 = SymmetricEncryption.Encryptor.fixed_encrypt(@long_long_string)
    assert encrypted1 == encrypted2
  end
end
