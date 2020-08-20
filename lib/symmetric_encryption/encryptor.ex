defmodule SymmetricEncryption.Encryptor do
  alias SymmetricEncryption.{Cipher, Header, Config}

  def fixed_encrypt(data), do: encrypt(data, random_iv: false, compress: false)

  def encrypt(data, opts \\ []) when is_binary(data) do
    compress = Keyword.get(opts, :compress, true)
    random_iv = Keyword.get(opts, :random_iv, true)
    version = Keyword.get(opts, :version)

    # Don't compress anything shorter than 64 bytes
    compress = if compress && (byte_size(data) <= 64), do: false, else: compress

    cipher = build_cipher(random_iv, false, version)
    header = build_header(random_iv, false, compress, cipher)

    data = if compress, do: :zlib.compress(data), else: data

    Header.serialize(header) <> Cipher.encrypt(cipher, data)
    |> Base.encode64()
  end

  defp build_cipher(random_iv, random_key, version) do
    Config.cipher(version)
    |> cipher_key(random_key)
    |> cipher_iv(random_iv)
  end

  defp cipher_key(cipher, false), do: cipher
  defp cipher_key(cipher, true) do
    Cipher.random_key(cipher)
  end

  defp cipher_iv(cipher, false), do: cipher
  defp cipher_iv(cipher, true) do
    Cipher.random_iv(cipher)
  end

  defp build_header(random_iv, random_key, compress, cipher) do
    %Header{version: cipher.version, compress: compress}
    |> header_key(random_key, cipher.key)
    |> header_iv(random_iv, cipher.iv)
  end

  defp header_key(header, false, _), do: header
  defp header_key(header, true, key) do
    Map.put(header, :key, key)
  end

  defp header_iv(header, false, _), do: header
  defp header_iv(header, true, iv) do
    Map.put(header, :iv, iv)
  end
end
