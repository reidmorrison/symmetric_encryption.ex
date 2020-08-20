# Symmetric Encryption Header
#
# Consists of:
#    4 Bytes: Magic Header Prefix: @Enc
#    1 Byte:  The version of the cipher used to encrypt the data, and key if present.
#    1 Byte:  Flags:
#       Bit 1: Whether the data is compressed
#       Bit 2: Whether the IV is included
#       Bit 3: Whether the Encrypted Key is included
#       Bit 4: Whether the Cipher Name is included
#       Bit 5: Whether the Auth Tag is included
#       Bit 6: Future use
#       Bit 7: Future use
#       Bit 8: Future use
#    2 Bytes: IV Length (little endian), if included.
#      IV in binary form.
#    2 Bytes: Key Length (little endian), if included.
#      Encrypted Key in binary form
#    2 Bytes: Cipher Name Length (little endian), if included.
#      Cipher name is UTF8 text
#    2 Bytes: Auth Tag Length (little endian), if included.
#      Auth Tag is binary data
defmodule SymmetricEncryption.Header do
  defstruct(
    version: 1,
    compress: false,
    iv: nil,
    encrypted_key: nil,
    cipher_name: nil,
    auth_tag: nil
  )

  @openssl_cipher_name_map %{"aes256cbc" => :aes_cbc256}

  def compressed?(header = %SymmetricEncryption.Header{}), do: header.compress == true

  def header?(buffer) when is_binary(buffer), do: String.starts_with?(buffer, "@EnC")

  def deserialize(buffer)  do
    <<
      64,
      69,
      110,
      67,
      version :: 8,
      compress :: 1,
      iv :: 1,
      encrypted_key :: 1,
      cipher_name :: 1,
      auth_tag :: 1,
      0 :: 3,
      remainder :: binary
    >> = buffer

    {remainder, iv} = deserialize_string(remainder, iv)
    {remainder, encrypted_key} = deserialize_string(remainder, encrypted_key)
    {remainder, cipher_name} = deserialize_cipher_name(remainder, cipher_name)
    {remainder, auth_tag} = deserialize_string(remainder, auth_tag)

    {
      remainder,
      %SymmetricEncryption.Header{
        version: version,
        compress: compress == 1,
        iv: iv,
        encrypted_key: encrypted_key,
        cipher_name: cipher_name,
        auth_tag: auth_tag
      }
    }
  end

  def serialize(header) do
    <<64, 69, 110, 67, header.version :: 8>>
    |> serialize_flags(header)
    |> serialize_string(header.iv)
    |> serialize_string(header.encrypted_key)
    |> serialize_string(header.cipher_name)
    |> serialize_string(header.auth_tag)
  end

  defp deserialize_string(buffer, 0), do: {buffer, nil}
  defp deserialize_string(buffer, 1) do
    <<length :: little - 16, remainder :: binary>> = buffer
    <<string :: binary - size(length), remainder :: binary>> = remainder
    {remainder, string}
  end

  defp deserialize_cipher_name(buffer, 0), do: {buffer, nil}
  defp deserialize_cipher_name(buffer, value) do
    {remainder, cipher_name} = deserialize_string(buffer, value)
    cipher_name = @openssl_cipher_name_map[cipher_name] || cipher_name
    {remainder, cipher_name}
  end

  defp serialize_string(data, nil), do: data
  defp serialize_string(data, string) do
    data <> <<byte_size(string) :: little - 16>> <> string
  end

  defp serialize_flags(data, header) do
    data <> <<
      serialize_flag(header.compress) :: 1,
      serialize_flag(header.iv) :: 1,
      serialize_flag(header.encrypted_key) :: 1,
      serialize_flag(header.cipher_name) :: 1,
      serialize_flag(header.auth_tag) :: 1,
      0 :: 3
    >>
  end

  defp serialize_flag(nil), do: 0
  defp serialize_flag(false), do: 0
  defp serialize_flag(_), do: 1
end
