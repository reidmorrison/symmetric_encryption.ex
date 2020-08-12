defmodule HeaderTest do
  use ExUnit.Case
  doctest SymmetricEncryption.Header

  test "serializes header with version" do
    header = %SymmetricEncryption.Header{version: 5}
    assert SymmetricEncryption.Header.serialize(header) == <<64, 69, 110, 67, 5, 0>>
  end

  test "serializes header with invalid version" do
    header = %SymmetricEncryption.Header{version: 256}
    assert SymmetricEncryption.Header.serialize(header) == <<64, 69, 110, 67, 0, 0>>
  end

  test "serializes header with compression" do
    header = %SymmetricEncryption.Header{compress: true}
    assert SymmetricEncryption.Header.serialize(header) == <<64, 69, 110, 67, 1, 128>>
  end

  test "serializes header with iv" do
    header = %SymmetricEncryption.Header{iv: "BLAH"}
    assert SymmetricEncryption.Header.serialize(header) == <<64, 69, 110, 67, 1, 64, 4, 0, 66, 76, 65, 72>>
  end

  test "serializes header with everything" do
    header = %SymmetricEncryption.Header{version: 255, compress: true, iv: "1234567890123456"}
    data = <<64, 69, 110, 67, 255, 192, 16, 0, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54>>
    assert data == SymmetricEncryption.Header.serialize(header)
  end

  test "deserializes header with version" do
    encrypted = <<201, 55, 139, 142, 193, 211, 107, 204, 164, 160, 239, 121, 43, 66, 144, 154>>
    data = <<64, 69, 110, 67, 5, 0>> <> encrypted
    {^encrypted, header} = SymmetricEncryption.Header.deserialize(data)
    assert %SymmetricEncryption.Header{version: 5} == header
  end

  test "deserializes header with compression" do
    {"", header} = SymmetricEncryption.Header.deserialize(<<64, 69, 110, 67, 1, 128>>)
    assert %SymmetricEncryption.Header{compress: true} == header
  end

  test "deserializes header with iv" do
    {"", header} = SymmetricEncryption.Header.deserialize(<<64, 69, 110, 67, 1, 64, 4, 0, 66, 76, 65, 72>>)
    assert %SymmetricEncryption.Header{iv: "BLAH"} == header
  end

  test "deserializes header with everything" do
    data = <<64, 69, 110, 67, 255, 192, 16, 0, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54>>
    {"", header} = SymmetricEncryption.Header.deserialize(data)
    assert %SymmetricEncryption.Header{version: 255, compress: true, iv: "1234567890123456"} == header
  end

  test "deserializes header with encrypted data" do
    data = <<64, 69, 110, 67, 255, 192, 16, 0, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54, 66, 76, 65, 72>>
    {"BLAH", header} = SymmetricEncryption.Header.deserialize(data)
    assert %SymmetricEncryption.Header{version: 255, compress: true, iv: "1234567890123456"} == header
  end

  test "deserializes ruby header" do
    {:ok, ruby} = "QEVuQwAANMt0wLnrkjgevJ9UgJt91w=="
                  |> Base.decode64
    {encrypted, header} = SymmetricEncryption.Header.deserialize(ruby)
    assert %SymmetricEncryption.Header{version: 0} == header
    assert encrypted == <<52, 203, 116, 192, 185, 235, 146, 56, 30, 188, 159, 84, 128, 155, 125, 215>>
  end

  test "deserializes ruby header with everything" do
    {:ok, ruby} = "QEVuQwDAEADjNfKNxPuxAmEBWIa0a0XUYVinJww/Li+rlQzmUTO2+EQ7sEMGPnhDzsgLCZUTE2E="
                  |> Base.decode64
    {_encrypted, header} = SymmetricEncryption.Header.deserialize(ruby)
    iv =  <<227, 53, 242, 141, 196, 251, 177, 2, 97, 1, 88, 134, 180, 107, 69, 212>>
    assert %SymmetricEncryption.Header{version: 0, compress: true, iv: iv} == header
  end
end
