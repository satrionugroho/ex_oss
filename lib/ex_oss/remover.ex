defmodule ExOss.Remover do
  @moduledoc false

  alias ExOss.Config
  alias ExOss.Authorization
  alias ExOss.Endpoint

  def delete_object(object, options \\ []) do
    with date <- Keyword.get(options, :date, Config.gmt_now()),
         authorization <- Authorization.generate("DELETE", date: date, key: object, headers: options),
         uri = Endpoint.bucket() |> Map.put(:path, "/" <> object) do
      headers = [
        {"Host", uri.host},
        {"Accept-Encoding", "identity"},
        {"Date", date},
        {"Authorization", authorization},
        {"Accept", "*/*"}
      ]

      ExOss.HTTP.delete(uri, headers)
    end
  end
end
