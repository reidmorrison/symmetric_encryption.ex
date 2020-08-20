defmodule SymmetricEncryption.Decryptor do
  alias SymmetricEncryption.{Config, Header, Cipher}

  def parse_header(encoded) do
    decode(encoded)
    |> Header.deserialize()
  end

  def decrypt(encoded) when is_binary(encoded) do
    {encrypted, header} = parse_header(encoded)

    build_cipher(header)
    |> Cipher.decrypt(encrypted)
    |> uncompress(header.compress)
  end

  def encrypted?(data) when is_binary(data) do
    case Base.decode64(data) do
      :error -> false
      {:ok, decoded} -> Header.header?(decoded)
    end
  end

  # Returns the Cipher that can be used to decrypt the data following this header.
  defp build_cipher(header) do
    Config.cipher(header.version)
    |> cipher_random_key(header.encrypted_key)
    |> cipher_random_iv(header.iv)
  end

  defp cipher_random_key(cipher, nil), do: cipher
  defp cipher_random_key(cipher, encrypted_key) do
    key = Cipher.decrypt(cipher, encrypted_key)
    Map.put(cipher, :key, key)
  end

  defp cipher_random_iv(cipher, nil), do: cipher
  defp cipher_random_iv(cipher, iv) do
    Map.put(cipher, :iv, iv)
  end

  defp uncompress(data, false), do: data
  defp uncompress(compressed, true) do
    :zlib.uncompress(compressed)
  end

  defp decode(data) do
    case Base.decode64(data) do
      :error -> raise(ArgumentError, message: "Cannot parse invalid Base64 encoded encrypted string")
      {:ok, decoded} -> decoded
    end
  end
end
