defmodule ExOss.HTTP do
  @moduledoc false

  def put(uri, object, headers) when is_bitstring(uri), do: uri |> URI.parse() |> put(object, headers)
  def put(%URI{} = uri, object, headers) do
    filename = uri.path
    case HTTPoison.put(URI.to_string(uri), {:file, object}, headers) do
      {:ok, %{status_code: 200} = response} -> Map.put(response, :filename, filename)
      response -> response
    end
  end

  def get(uri, headers \\ [], params \\ %{})
  def get(%URI{} = uri, headers, params), do: uri |> URI.to_string() |> get(headers, params)
  def get(uri, headers, params) when is_bitstring(uri), do: HTTPoison.get(uri, headers, params: params)

  def delete(%URI{} = uri, headers), do: uri |> URI.to_string() |> delete(headers)
  def delete(uri, headers) when is_bitstring(uri), do: HTTPoison.delete(uri, headers)
end
