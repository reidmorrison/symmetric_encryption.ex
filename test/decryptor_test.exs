defmodule DecryptorTest do
  use ExUnit.Case
  doctest SymmetricEncryption.Decryptor

  @long_string "This is a really long string for testing compression that needs to span more than one AES block."

  test "decrypts" do
    encrypted = SymmetricEncryption.Encryptor.encrypt("Hello World")
    decrypted = SymmetricEncryption.Decryptor.decrypt(encrypted)
    assert decrypted == "Hello World"
  end

  test "decrypts with insecure iv" do
    encrypted = SymmetricEncryption.Encryptor.insecure_encrypt("Hello World")
    decrypted = SymmetricEncryption.Decryptor.decrypt(encrypted)
    assert decrypted == "Hello World"
  end

  test "decrypts old data" do
    encrypted = SymmetricEncryption.Encryptor.encrypt("Hello World", version: 1)
    decrypted = SymmetricEncryption.Decryptor.decrypt(encrypted)
    assert decrypted == "Hello World"
  end

  test "decrypts compressed data" do
    encrypted = SymmetricEncryption.Encryptor.encrypt(@long_string <> @long_string, compress: true)
    decrypted = SymmetricEncryption.Decryptor.decrypt(encrypted)
    assert decrypted == @long_string <> @long_string
  end

  test "decrypts compressed data with insecure iv" do
    encrypted = SymmetricEncryption.Encryptor.encrypt(@long_string <> @long_string, compress: true, random_iv: false)
    decrypted = SymmetricEncryption.Decryptor.decrypt(encrypted)
    assert decrypted == @long_string <> @long_string
  end

  test "decrypts ruby Symmetric Encryption created encrypted values" do
    ruby_test_cases = [
      "QEVuQwIAPiplaSyln4bywEKXYKDOqQ==",
      "QEVuQwLAEAAUUK3A2qFln+petIdoFo6ihsgx2CvBPvcBFwo7V5RYgcDmW+MpT292YMtKWuG71Pw=",
      "QEVuQwJAEACS5D3Zubp0QSHsldaChoVmbWDebv06m/6cEM3M1tsu7Q==",
      "QEVuQwIAPiplaSyln4bywEKXYKDOqQ==",
      "QEVuQwKAUCO79g/TdyktDQ2v0uLvjWMkv96fw9TBDEEJFBi1OE8=",
      "QEVuQwJAEAAZqZ/igsACHBIwKMQgw2UeqJ/qnNhY/1snkESvqzg+mA==",
    ]
    Enum.each(ruby_test_cases, fn str -> assert SymmetricEncryption.decrypt(str) == "Hello World" end)
  end
end
