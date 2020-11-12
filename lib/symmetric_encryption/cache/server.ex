defmodule SymmetricEncryption.Cache.Server do
  use GenServer
  require Logger

  alias SymmetricEncryption.Cipher

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(nil) do
    init_ciphers = Application.get_env(:symmetric_encryption, :ciphers)
    set_ciphers([])
    add_ciphers(init_ciphers)

    {:ok, nil}
  end

  def add_ciphers(cipher_fun) when is_function(cipher_fun) do
    cipher_fun.()
    |> add_ciphers()
  end

  def add_ciphers(ciphers) do
    (ciphers || [])
    |> Enum.each(&add_cipher/1)
  end

  def add_cipher(m) do
    (ciphers() ++ [Cipher.new(m)])
    |> set_ciphers()
  end

  def ciphers() do
    Application.get_env(:symmetric_encryption, :ciphers)
  end

  defp set_ciphers(ciphers) do
    Application.put_env(:symmetric_encryption, :ciphers, ciphers)
  end
end
