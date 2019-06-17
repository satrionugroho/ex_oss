defmodule ExOss.Uploader do
  @moduledoc false

  alias ExOss.Config
  alias ExOss.Authorization
  alias ExOss.Endpoint

  def put_object(object, options \\ []) when is_bitstring(object) do
    with true <- File.exists?(object),
         {:ok, info} <- File.stat(object),
         filename <- Config.upload_placement(object, options),
         size <- Map.get(info, :size, 0),
         date <- Keyword.get(options, :date, Config.gmt_now()),
         content_type <- MIME.from_path(object),
         authorization <- Authorization.generate("PUT", date: date, size: size, key: filename, content_type: content_type, content_md5: "", headers: options),
         uri = Endpoint.bucket() |> Map.put(:path, filename) do

      headers = [
        {"Authorization", authorization},
        {"Content-Length", size},
        {"Date", date},
        {"Accept", "*/*"},
        {"Content-Type", content_type},
      ]

      ExOss.HTTP.put(uri, object, headers)
    else
      false -> raise ArgumentError, "File not found"
      {:error, reason} -> raise ArgumentError, reason
    end
  end
end
