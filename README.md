# B2

Elixir wrapper of [B2 Cloud Storage](https://www.backblaze.com/b2/cloud-storage.html)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add b2 to your list of dependencies in `mix.exs`:

        def deps do
          [{:b2, "~> 0.0.1"}]
        end

  2. Ensure b2 is started before your application:

        def application do
          [applications: [:b2]]
        end

  3. Puts config your `config.exs`

```elixir
config :your_application, :b2,
  account_id: "your account id",
  application_key: "your application key"
```

## Usage

```elixir
B2.File.upload(bucket_id, file_name, content_type, file_path)
```
