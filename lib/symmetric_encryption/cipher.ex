# An encryption cipher is used to encrypt and decrypt data.
#
# This Cipher supports
# - AES encryption with the CBC block cipher.
# - Any valid encryption key size
#
# The number of bits in a key is determined by the length of the symmetric key that is generated or supplied.
defmodule SymmetricEncryption.Cipher do
  defstruct(
    key: nil,
    iv: nil,
    version: 1
  )

  def new(cipher = %SymmetricEncryption.Cipher{}) do
    cipher
  end

  def new(%{key: key, iv: iv, version: version}) do
    %SymmetricEncryption.Cipher{key: key, iv: iv, version: version}
  end

  # Returns a new cipher with randomized symmetric key and initialization vector.
  #
  # The initialization vector is used when SymmetricEncryption.fixed_encrypt is called.
  def randomize(cipher \\ %SymmetricEncryption.Cipher{}) do
    cipher
    |> random_key()
    |> random_iv()
  end

  def randomize(cipher = %SymmetricEncryption.Cipher{}, 256), do: randomize(cipher)

  def randomize(cipher = %SymmetricEncryption.Cipher{}, 128) do
    cipher
    |> random_key(128)
    |> random_iv()
  end

  # Assign a new random encryption key to this cipher.
  def random_key(cipher \\ %SymmetricEncryption.Cipher{}) do
    Map.put(cipher, :key, :crypto.strong_rand_bytes(32))
  end

  def random_key(cipher = %SymmetricEncryption.Cipher{}, 256), do: random_key(cipher)

  def random_key(cipher = %SymmetricEncryption.Cipher{}, 128) do
    Map.put(cipher, :key, :crypto.strong_rand_bytes(16))
  end

  # Assign a new random initialization to this cipher.
  def random_iv(cipher \\ %SymmetricEncryption.Cipher{}) do
    Map.put(cipher, :iv, :crypto.strong_rand_bytes(16))
  end

  def encrypt(cipher, data) do
    data = append_padding(data)

    cipher_name(cipher)
    |> :crypto.block_encrypt(cipher.key, cipher.iv, data)
  end

  def decrypt(cipher, encrypted) do
    cipher_name(cipher)
    |> :crypto.block_decrypt(cipher.key, cipher.iv, encrypted)
    |> strip_padding()
  end

  # Encryption key strength.
  defp key_strength(nil) do
    raise(ArgumentError,
      message: "Please set the key prior to calling methods on SymmetricEncryption.cipher"
    )
  end

  defp key_strength(key) do
    byte_size(key) * 8
  end

  defp cipher_name(cipher) do
    ("aes_cbc" <> to_string(key_strength(cipher.key)))
    |> String.to_atom()
  end

  defp strip_padding(str) do
    len = byte_size(str)
    all_but_last = len - 1
    <<_::binary-size(all_but_last), last::8>> = str
    length = len - last
    <<string::binary-size(length), _::binary>> = str
    string
  end

  defp append_padding(str) do
    block_size = 16
    len = byte_size(str)
    pad_len = block_size - rem(len, block_size)

    padding =
      <<pad_len>>
      |> List.duplicate(pad_len)
      |> Enum.join("")

    str <> padding
  end
end
