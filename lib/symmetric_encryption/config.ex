defmodule SymmetricEncryption.Config do
  alias SymmetricEncryption.Key

  # Current active global key
  def key() do
    List.first(keys())
  end

  # Request a specific version of a key
  def key(version) do
    Enum.find(keys(), fn key -> key.version == version end) ||
      raise(ArgumentError, message: "Key version #{version} is not available on this system.")
    #    key = Enum.find(keys(), fn key -> key.version == version end)
    #    if is_nil(key), do: raise(ArgumentError, message: "Key version #{version} is not available on this system.")
    #    key
  end

  # Hardcoded Placeholder for global key
  def keys() do
    [
      %Key{
        cipher: :aes_cbc256,
        key: "ABCDEF1234567890ABCDEF1234567890",
        iv: "ABCDEF1234567890",
        version: 2
      },
      %Key{
        cipher: :aes_cbc256,
        key: "1234567890ABCDEF1234567890ABCDEF",
        iv: "1234567890ABCDEF",
        version: 1
      },
    ]
  end
end
