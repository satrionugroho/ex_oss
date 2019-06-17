## Ex OSS (Object Storage Service)
Minimal implementation for Alibaba Object Storage Service for elixir, can be integrated with `Arc` for better cloud file management.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_oss` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_oss, "~> 0.1.0"}
  ]
end
```

Or checkout with github instead

```elixir
def deps do
  [
    {:ex_oss, github: "satrionugroho/ex_oss"}
  ]
end
```

## Configuration
To store your attachments in `Alibaba Object Storage Service`, you'll need to provide a bucket and region to your application config

```elixir
config :ex_oss,
  access_key_id: "<your_alibaba_ram_access_key_id>",
  secret_access_key: "<your_alibaba_ram_access_secret_key_id>",
  region: "oss-cn-hangzhou",
  bucket: "your-bucket"
```

For integration with `Arc`, must change storage in `Arc` configuration

```elixir
config :arc,
  storage: ExOss.Bridge.Arc
```

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Added some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## License and Author
Author: 2019 Satrio Nugroho
This project is licensed under the MIT license, a copy of which can be found in the [LICENSE]("LICENSE.md") file.
