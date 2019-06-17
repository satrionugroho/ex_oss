defmodule ExOss.Authorization do
  @moduledoc false

  alias ExOss.Config

  def generate(verb, options \\ []), do: "OSS #{Map.get(Config.default(), :access_key_id)}:#{signature(verb, options)}"

  defp signature(verb, options) do
    key          = Keyword.get(options, :key)
    content_type = Keyword.get(options, :content_type, "")
    content_md5  = Keyword.get(options, :content_md5, "")
    secret       = Config.default() |> Map.get(:secret_access_key, "")
    headers      = Keyword.get(options, :headers, [])
    date         = case Keyword.has_key?(headers, :link) do
      true -> Config.expires_for(hours: 1)
      false -> Keyword.get(options, :date, Config.gmt_now())
    end

    canonicalized_headers  = canonicalized_headers(headers)
    canonicalized_resource = case String.starts_with?(key, "/") do
      false -> canonicalized_resource(key)
      _ ->
        <<_::binary-size(1), rest::binary>> = key
        canonicalized_resource(rest)
    end

    string = verb                  <> "\n"                   <>
             content_md5           <> "\n"                   <>
             content_type          <> "\n"                   <>
             date                  <> "\n"                   <>
             canonicalized_headers <> canonicalized_resource

    :sha
    |> :crypto.hmac(secret, string)
    |> Base.encode64()
  end

  defp canonicalized_headers(list, canon \\ "")
  defp canonicalized_headers([], canon), do: canon
  defp canonicalized_headers([{key, value} | rest], canon) do
    string_key = Kernel.to_string(key)

    case String.contains?(string_key, "x-oss-") do
      true ->
        true_key = String.downcase(key) |> String.trim()
        true_value = String.trim(value)

        canonicalized_headers(rest, "#{canon}#{true_key}:#{true_value}\n")
      false -> canonicalized_headers(rest, canon)
    end
  end

  defp canonicalized_resource(key) when is_bitstring(key), do: "/" <> Map.get(Config.default(), :bucket) <> "/" <> key
  defp canonicalized_resource(_), do: "/"
end
