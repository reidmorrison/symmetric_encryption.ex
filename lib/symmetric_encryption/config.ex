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

  # Hardcoded Placeholder for global cipher
  def ciphers() do
    [
      %Cipher{
        key: "ABCDEF1234567890ABCDEF1234567890",
        iv: "ABCDEF1234567890",
        version: 2
      },
      %Cipher{
        key: "1234567890ABCDEF1234567890ABCDEF",
        iv: "1234567890ABCDEF",
        version: 1
      },
    ]
  end
end
