# Symmetric Encryption for Elixir

Encrypt and decrypt data using the same encryption key, both inflight and whilst at rest.

Ideal Uses:
- Encrypt data for internal use by your application.

## Status

Early prototype code, not for production use.

## Objectives

- Render encrypted data unusable to unauthorized parties.
- Encrypt internal data in flight and at rest.
- Support regular encryption key rotation.
    - Example: Use new keys annually, or a new one every month, etc.
- Support prior encryption keys to transparently read data encrypted with old and new encryption keys.
    - Example: Live switch encryption keys and slowly re-encrypt data in the database.
    - Supports up to 254 previous encryption keys.
- Encourage the use of a random initialization vector (IV) with every encryption.
- Automatically compress data using zlib for everything except very small data.
- Support strong AES encryption with CBC block cipher. Use 256 bit keys by default.
- Keep the encryption header small, yet include enough information so that every encrypted value
    identifies which encryption key was used to encrypt it.  
- Autodetect key bit size based on key length supplied.
- Encode encrypted data with strict Base 64 to make it more database friendly.
- Encrypted data is compatibile with [Symmetric Encryption for Ruby](https://encryption.rocketjob.io).
    - Allow both Ruby and Elixir to read and write the same encrypted data. 

## Not intended for

- Sharing encrypted data with third parties. See OpenPGP.

## Considerations

- Only supports AES Symmetric Encryption using the CBC block cipher.
- Does not use RSA or any other public/private key pairs.
- Recommend at least a 256 bit key length. 
  128 bit should only be used for testing and development purposes.
  
### Initialization Vector

It is best to always use a random initilization vector (IV), which Symmetric Encryption implements
by default when calling `SymmetricEncryption.encrypt/2`.

Disadvantages:
- Encrypted data is slightly larger because it includes the random IV.
- Encrypting the same data twice results in different encrypted values.
- The encrypted value cannot be used for database lookups.

When encrypted data needs to be used as a lookup key, it cannot be encrypted using a random IV every time, since
the same plain text data will always result in different encrypted text.
For example, bank account number, or social security number. 
            
The method `SymmetricEncryption.fixed_encrypt/1` should be used in this case to disable the random IV generation, 
as well as compression.
It ensures that for the same input plain text value, it will always return the same output encrypted value when
using the same cipher.

## Ruby Compatibility

Compatible with [Symmetric Encryption for Ruby](https://encryption.rocketjob.io).
The following rare edge cases are not supported in the Elixir version:
- Encrypted data _without_ an encryption header.
- Encoding other than Base 64 strict.
- When writing encrypted files do not override the cipher name.
- Encryption other than AES. 
- Block ciphers other than CBC. 

Additionally the following changes have been made over the Ruby version:
- Encrypting data using `SymmetricEncryption.encrypt/2` will generate a random IV and compress the supplied data by default.

## Installation

TODO:

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `symmetric_encryption` to your list of dependencies in `mix.exs`:

~~~elixir
def deps do
  [
    {:symmetric_encryption, "~> 0.1"}
  ]
end
~~~

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/symmetric_encryption](https://hexdocs.pm/symmetric_encryption).

## Usage

Encrypt String data.
~~~elixir
iex> SymmetricEncryption.encrypt("Hello World")
"QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="
~~~

Decrypt String data.
~~~elixir
iex> encrypted = SymmetricEncryption.encrypt("Hello World")
"QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="
iex> SymmetricEncryption.decrypt(encrypted)
"Hello World"
~~~

Is the string encrypted?
~~~elixir
iex> encrypted = SymmetricEncryption.encrypt("Hello World")
"QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="
iex> SymmetricEncryption.encrypted?(encrypted)
true
iex> SymmetricEncryption.encrypted?("Hello World")
false
~~~

Return the header for an encrypted string.
~~~elixir
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
~~~

Always return the same encrypted value for the same input data.

The same global IV is used to generate the encrypted data, which is considered insecure since
too much encrypted data using the same key and IV can allow hackers to reverse the key.

The same encrypted value is returned every time the same data is encrypted, which is useful
when the encrypted value is used with database lookups etc.

~~~elixir
iex> SymmetricEncryption.fixed_encrypt("Hello World")
"QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="
iex> SymmetricEncryption.fixed_encrypt("Hello World")
"QEVuQwIAPiplaSyln4bywEKXYKDOqQ=="
~~~

## Author

[Reid Morrison](https://github.com/reidmorrison)

[Contributors](https://github.com/reidmorrison/symmetric_encryption/graphs/contributors)

## Versioning

This project uses [Semantic Versioning](http://semver.org/).
