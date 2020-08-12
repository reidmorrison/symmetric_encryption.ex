defmodule SymmetricEncryption.Decryptor do
  alias SymmetricEncryption.{Config, Header}

  def parse_header(encoded) do
    decode(encoded)
    |> Header.deserialize()
  end

  def decrypt(encoded) when is_binary(encoded) do
    {encrypted, header} = parse_header(encoded)

    key = Config.key(header.version)
    encrypted
    |> decrypt(
         Header.key(header) || key.key(),
         header.iv() || key.iv(),
         key.cipher(),
         header.auth_tag()
       )
    |> uncompress(header.compress)
  end

  def encrypted?(data) when is_binary(data) do
    case Base.decode64(data) do
      :error -> false
      {:ok, decoded} -> Header.header?(decoded)
    end
  end

  # Private internal use only method.
  def decrypt(encrypted, aes_key, iv, cipher, auth_tag) when is_binary(encrypted) do
    encrypted
    |> block_decrypt(aes_key, iv, cipher, auth_tag)
    |> strip_padding()
  end

  defp uncompress(data, false), do: data
  defp uncompress(compressed, true) do
    :zlib.uncompress(compressed)
  end

  defp strip_padding(str) do
    len = byte_size(str)
    all_but_last = len - 1
    << _ :: binary-size(all_but_last), last :: 8 >> = str
    length = len - last
    << string :: binary-size(length), _ :: binary>> = str
    string
  end

  defp decode(data) do
    case Base.decode64(data) do
      :error -> raise(ArgumentError, message: "Cannot parse invalid Base64 encoded encrypted string")
      {:ok, decoded} -> decoded
    end
  end

  defp block_decrypt(encrypted, aes_key, iv, :aes_cbc256, _auth_tag) do
    :crypto.block_decrypt(:aes_cbc256, aes_key, iv, encrypted)
  end

  defp block_decrypt(encrypted, aes_key, iv, :aes_gcm256, auth_tag) do
    :crypto.block_decrypt(:aes_gcm, aes_key, iv, {"aes256gcm", encrypted, auth_tag})
  end
end
