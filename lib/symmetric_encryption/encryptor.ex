defmodule SymmetricEncryption.Encryptor do
  alias SymmetricEncryption.{Key, Header, Config}

  def insecure_encrypt(data), do: encrypt(data, random_iv: false)

  def encrypt(data, opts \\ []) when is_binary(data) do
    compress = Keyword.get(opts, :compress, false)
    random_iv = Keyword.get(opts, :random_iv, true)
    random_key = Keyword.get(opts, :random_key, false)
    version = Keyword.get(opts, :version)

    key = build_key(random_iv, random_key, version)
    header = build_header(random_iv, random_key, compress, key)

    # No point in compressing anything shorter than 64 bytes
    compress = if compress && byte_size(data) <= 64, do: false, else: compress
    data = if compress, do: :zlib.compress(data), else: data

    {encrypted, auth_tag} = binary_encrypt(data, key.key(), key.iv(), key.cipher())
    header = if is_nil(auth_tag), do: header, else: Map.put(header, :auth_tag, auth_tag)

    encrypted
    |> add_header(header)
    |> Base.encode64()
  end

  # Private internal use only method.
  def binary_encrypt(data, key, iv, cipher) when is_binary(data) do
    data
    |> append_padding()
    |> block_encrypt(key, iv, cipher)
  end

  defp append_padding(str) do
    block_size = 16
    len = byte_size(str)
    pad_len = block_size - rem(len, block_size)
    padding = <<pad_len>>
              |> List.duplicate(pad_len)
              |> Enum.join("")
    str <> padding
  end

  defp build_key(random_iv, random_key, version) do
    key = if is_nil(version), do: Config.key(), else: Config.key(version)
    key = if random_iv, do: Key.random_iv(key), else: key
    key = if random_key, do: Key.random_key(key), else: key
    key
  end

  defp build_header(random_iv, random_key, compress, key) do
    version = if random_key, do: 0, else: key.version()

    header = %Header{version: version, compress: compress}
    header = if random_iv, do: Map.put(header, :iv, key.iv()), else: header
    header = if random_key, do: Map.put(header, :random_iv, key.key()), else: header
    header
  end

  defp add_header(data, header) do
    Header.serialize(header) <> data
  end

  defp block_encrypt(data, key, iv, :aes_cbc256) do
    encrypted = :crypto.block_encrypt(:aes_cbc256, key, iv, data)
    {encrypted, nil}
  end

  defp block_encrypt(data, key, iv, :aes_gcm256) do
    :crypto.block_encrypt(:aes_gcm, key, iv, {"aes256gcm", data})
  end
end
