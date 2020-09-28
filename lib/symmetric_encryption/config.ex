defmodule SymmetricEncryption.Config do
  alias SymmetricEncryption.Cipher

  # Current active global cipher
  def cipher() do
    ciphers()
    |> List.first()
  end

  def cipher(nil), do: cipher()

  # Request a specific version of a cipher
  def cipher(version) do
    Enum.find(ciphers(), fn cipher -> cipher.version == version end) ||
      raise(ArgumentError, message: "Cipher version #{version} is not available on this system.")
  end

  # Returns a List of ciphers from memory
  def ciphers() do
    GenServer.call(SymmetricEncryption.Cache.Server, {:ciphers})
  end

  def add_cipher(c = %Cipher{} ) do
    GenServer.call(SymmetricEncryption.Cache.Server, {:add_cipher, c})
  end
end
