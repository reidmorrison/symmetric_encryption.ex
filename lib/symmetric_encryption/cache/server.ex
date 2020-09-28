defmodule SymmetricEncryption.Cache.Server do
  use GenServer
  require Logger

  alias SymmetricEncryption.Cipher

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle_call({:set_cipher, m = %Cipher{}}, _from, state) do
    {:reply, m, state ++ [m]}
  end

  def handle_call({:get_ciphers}, _from, state) do
    {:reply, state, state}
  end

end
