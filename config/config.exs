use Mix.Config

# Test keys
config :symmetric_encryption,
       key: [
         key: "ABCDEF1234567890ABCDEF1234567890",
         iv: "ABCDEF1234567890",
         version: 2
       ]
config :symmetric_encryption,
       old_keys: [
         [key: "1234567890ABCDEF1234567890ABCDEF", iv: "1234567890ABCDEF", version: 1]
       ]
