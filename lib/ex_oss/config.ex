defmodule ExOss.Config do
  @moduledoc false

  @alphabets [97..122, 48..57, 65..90]
  |> Enum.map(&Enum.to_list/1)
  |> Enum.join()
  |> String.codepoints()

  def default do
    Application.get_all_env(:ex_oss)
    |> Enum.into(%{
      access_key_id: nil,
      secret_access_key: nil,
      region: "oss-cn-hangzhou",
      bucket: nil
    })
  end

  # Sun, 22 Nov 2015 08:16:38 GMT
  def gmt_now do
    Timex.now()
    |> Timex.Timezone.convert("GMT")
    |> Timex.format!("{WDshort}, {D} {Mshort} {YYYY} {h24}:{m}:{s} {Zabbr}")
  end

  def expires_for(opts \\ [hours: 1]) when is_list(opts) do
    Timex.now()
    |> Timex.shift(opts)
    |> Timex.to_unix()
    |> Kernel.to_string()
  end
  def expires_for(_), do: expires_for(hours: 1) |> Kernel.to_string()

  def upload_name(length \\ 32), do: Enum.map_join(1..length, fn _ -> Enum.random(@alphabets) end)

  def upload_placement(object, options \\ []) do
    default_name = create_unique_upload_name(object, Keyword.get(options, :encrypted_name, false), options)
    name = Keyword.get(options, :filename, default_name)

    Keyword.get(options, :folder, "/")
    |> Kernel.to_string()
    |> add_prefix()
    |> add_suffix()
    |> Kernel.<>(name)
    |> add_extention(object)
  end

  defp add_suffix(folder) do
    case String.ends_with?(folder, "/") do
      true -> folder
      false -> folder <> "/"
    end
  end

  defp add_prefix(folder) do
    case String.starts_with?(folder, "/") do
      true -> folder
      false -> "/" <> folder
    end
  end

  defp create_unique_upload_name(_object, true, options), do: upload_name(Keyword.get(options, :length, 32))
  defp create_unique_upload_name(object, false, _options), do: Path.basename(object)

  defp add_extention(filename, object) do
    case Path.extname(filename) |> String.length() do
      0 -> filename <> Path.extname(object)
      _ -> filename
    end
  end
end
