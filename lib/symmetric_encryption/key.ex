# It is _not_ recommended to set the iv, so that `#encrypt/2` will generate a new IV with every encryption.
defmodule SymmetricEncryption.Key do
  defstruct(
    key: nil,
    iv: nil,
    cipher: :aes_cbc256,
    version: 1
  )

  # TODO: Instead of cipher, use block mode and strength, since AES is mandatory

  # Is an authenticated key being used?
  def authenticated?(%SymmetricEncryption.Key{cipher: :aes_cbc256}), do: false
  def authenticated?(%SymmetricEncryption.Key{cipher: :aes_gcm256}), do: true

  # Returns a new Key instance with randomized key and iv
  def randomize(key = %SymmetricEncryption.Key{}) do
    key
    |> random_key()
    |> random_iv()
  end

  def random_key(), do: random_key(%SymmetricEncryption.Key{})
  def random_key(key = %SymmetricEncryption.Key{cipher: :aes_cbc256}) do
    Map.put(key, :key, :crypto.strong_rand_bytes(32))
  end
  def random_key(key = %SymmetricEncryption.Key{cipher: :aes_gcm256}) do
    Map.put(key, :key, :crypto.strong_rand_bytes(32))
  end

  def random_iv(), do: random_iv(%SymmetricEncryption.Key{})
  def random_iv(key = %SymmetricEncryption.Key{cipher: :aes_cbc256}) do
    Map.put(key, :iv, :crypto.strong_rand_bytes(16))
  end
  def random_iv(key = %SymmetricEncryption.Key{cipher: :aes_gcm256}) do
    Map.put(key, :iv, :crypto.strong_rand_bytes(12))
  end
end
