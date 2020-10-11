defmodule EctoTypeTest do
  use ExUnit.Case, async: true
  @moduletag timeout: :infinity

  alias SymmetricEncryption.EctoType

  defmodule Schema do
    use Ecto.Schema

    @primary_key {:id, :binary_id, autogenerate: true}
    schema "" do
      field(:random, EctoType, random_iv: true)
      field(:fixed, EctoType, random_iv: false)
    end
  end

  test "custom types" do
    value = "My database value"
    fixed_encrypted_value = SymmetricEncryption.fixed_encrypt(value)
    random_encrypted_value = SymmetricEncryption.encrypt(value)
    assert EctoType.dump(value, nil, random_iv: false) == {:ok, fixed_encrypted_value}
    assert EctoType.load(fixed_encrypted_value, nil, random_iv: false) == {:ok, value}
    assert EctoType.load(random_encrypted_value, nil, random_iv: true) == {:ok, value}
    # Random doesn't matter for decrypting
    assert EctoType.load(random_encrypted_value, nil, random_iv: false) == {:ok, value}

    assert EctoType.dump(nil, nil, []) == {:ok, nil}
    assert EctoType.load(nil, nil, []) == {:ok, nil}
    assert EctoType.cast(nil, []) == {:ok, nil}
  end
end
