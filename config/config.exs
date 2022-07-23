import Config

# Test keys
config :symmetric_encryption,
  ciphers: [
    %{
      key: "ABCDEF1234567890ABCDEF1234567890",
      iv: "ABCDEF1234567890",
      version: 2
    },
    %{
      key: "1234567890ABCDEF1234567890ABCDEF",
      iv: "1234567890ABCDEF",
      version: 1
    }
  ]
