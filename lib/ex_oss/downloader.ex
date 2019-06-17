defmodule ExOss.Downloader do
  @moduledoc false

  alias ExOss.Config
  alias ExOss.Authorization
  alias ExOss.Endpoint

  @doc """
  Hello world.
  """
  def get_object(name, options \\ []) when is_bitstring(name) do
    %{headers: headers, params: params, uri: uri} = generate_headers(name, Keyword.has_key?(options, :link), options)

    ExOss.HTTP.get(uri, headers, params)
  end

  def get_object_link(name, options \\ []) do
    %{headers: _headers, params: params, uri: uri} = generate_headers(name, true, Keyword.put(options, :link, true))
    query =
      params
      |> Enum.map(fn {key, value} -> {key, URI.encode_www_form(value)} end)
      |> Enum.map(fn {key, value} -> key <> "=" <> value end)
      |> Enum.join("&")

    uri
    |> Map.put(:query, query)
    |> URI.to_string()
  end

  defp generate_headers(name, false, options) do
    %{
      uri: Endpoint.bucket() |> Map.put(:path, "/" <> name),
      headers: [
        {"Authorization", authorization(name, options)},
        {"Date", Keyword.get(options, :date, Config.gmt_now())},
        {"Host", Endpoint.bucket().host}
      ],
      params: %{}
    }
  end

  defp generate_headers(name, true, options) do
    [_oss, last] = String.split(authorization(name, options), " ")
    [access_id, signature] = String.split(last, ":")

    %{
      uri: Endpoint.bucket() |> Map.put(:path, "/" <> name),
      headers: [],
      params: %{
        "Expires" => Config.expires_for(hours: 1),
        "Signature" => signature,
        "OSSAccessKeyId" => access_id
      }}
  end

  defp authorization(name, options) do
    content_type = Keyword.get(options, :content_type, "")
    content_md5 = Keyword.get(options, :content_md5, "")
    Authorization.generate("GET", key: name, content_type: content_type, content_md5: content_md5, headers: options)
  end
end
