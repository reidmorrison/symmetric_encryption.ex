defmodule EncryptorTest do
  use ExUnit.Case
  #doctest SymmetricEncryption.Encryptor

  @long_string "This is a really long string for testing compression that needs to span more than one AES block."

  test "encrypts" do
    encrypted = SymmetricEncryption.Encryptor.encrypt("Hello World")
    assert byte_size(encrypted) == 56
  end

  test "compresses" do
    not_compressed = SymmetricEncryption.Encryptor.encrypt(@long_string <> @long_string, compress: false)
    compressed = SymmetricEncryption.Encryptor.encrypt(@long_string <> @long_string, compress: true)
    assert byte_size(not_compressed) > byte_size(compressed)
  end

  test "creates new iv when not supplied" do
    encrypted1 = SymmetricEncryption.Encryptor.encrypt("Hello World")
    encrypted2 = SymmetricEncryption.Encryptor.encrypt("Hello World")
    assert encrypted1 != encrypted2
  end

  test "insecure encrypts" do
    encrypted = SymmetricEncryption.Encryptor.insecure_encrypt("Hello World")
    assert byte_size(encrypted) == 32
  end

  test "use same iv" do
    encrypted1 = SymmetricEncryption.Encryptor.insecure_encrypt("Hello World")
    encrypted2 = SymmetricEncryption.Encryptor.insecure_encrypt("Hello World")
    assert encrypted1 == encrypted2
  end
end
