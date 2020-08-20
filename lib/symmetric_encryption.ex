defmodule SymmetricEncryption do
  @moduledoc """
  Symmetric Encryption.

  Supports AES symmetric encryption using the CBC block cipher.
  """

  @doc """
  Encrypt String data.

  ## Examples

      iex> SymmetricEncryption.encrypt("Hello World")
      "QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="

  """
  defdelegate encrypt(data), to: SymmetricEncryption.Encryptor

  @doc """
  Always return the same encrypted value for the same input data.

  The same global IV is used to generate the encrypted data, which is considered insecure since
  too much encrypted data using the same key and IV will allow hackers to reverse the key.

  The same encrypted value is returned every time the same data is encrypted, which is useful
  when the encrypted value is used with database lookups etc.

  ## Examples

      iex> SymmetricEncryption.fixed_encrypt("Hello World")
      "QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="
      iex> SymmetricEncryption.fixed_encrypt("Hello World")
      "QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="

  """
  defdelegate fixed_encrypt(data), to: SymmetricEncryption.Encryptor

  @doc """
  Decrypt String data.

  ## Examples

      iex> encrypted = SymmetricEncryption.encrypt("Hello World")
      "QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="
      iex> SymmetricEncryption.decrypt(encrypted)
      "Hello World"
  """
  defdelegate decrypt(encrypted), to: SymmetricEncryption.Decryptor

  @doc """
  Is the string encrypted?

  ## Examples

      iex> encrypted = SymmetricEncryption.encrypt("Hello World")
      "QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="
      iex> SymmetricEncryption.encrypted?(encrypted)
      true
      iex> SymmetricEncryption.encrypted?("Hello World")
      false
  """
  defdelegate encrypted?(encrypted), to: SymmetricEncryption.Decryptor

  @doc """
  Return the header for an encrypted string.

  ## Examples

      iex> encrypted = SymmetricEncryption.encrypt("Hello World")
      "QEVuQwJAEAAPX3a7EGJ7STMqIO8g38VeB7mFO/DC6DhdYljT4AmdFw=="

      iex> SymmetricEncryption.header(encrypted)
      %SymmetricEncryption.Header{
        auth_tag: nil,
        cipher_name: nil,
        compress: false,
        encrypted_key: nil,
        iv: <<15, 95, 118, 187, 16, 98, 123, 73, 51, 42, 32, 239, 32, 223, 197, 94>>,
        version: 2
      }
  """
  def header(encrypted) do
    {_, header} = SymmetricEncryption.Decryptor.parse_header(encrypted)
    header
  end
end
