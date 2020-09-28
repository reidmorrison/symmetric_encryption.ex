# Initialises the Genserver with the proper ciphers before running tests.

alias SymmetricEncryption.Cipher

Enum.each(
  [1, 2],
  fn version ->
    cipher = %Cipher{
      key: "ABCDEF1234567890ABCDEF1234567890",
      iv: "ABCDEF1234567890",
      version: version
    }
    SymmetricEncryption.add_cipher(cipher)
  end
)

ExUnit.start()
