defmodule ExOss.Endpoint do
  @moduledoc false

  alias ExOss.Config

  @regions [
    "oss-cn-hangzhou",
    "oss-cn-shanghai",
    "oss-cn-qingdao",
    "oss-cn-beijing",
    "oss-cn-zhangjiakou",
    "oss-cn-huhehaote",
    "oss-cn-shenzhen",
    "oss-cn-hongkong",
    "oss-us-west-1",
    "oss-us-east-1",
    "oss-ap-southeast-1",
    "oss-ap-southeast-2",
    "oss-ap-southeast-3",
    "oss-ap-southeast-4",
    "oss-ap-southeast-5",
    "oss-ap-norteast-1",
    "oss-ap-south-1",
    "oss-eu-central-1",
    "oss-eu-west-1",
    "oss-me-east-1"
  ]

  def uri do
    desired_region =
      Config.default()
      |> Map.get(:region)

    case Enum.member?(@regions, desired_region) do
      true -> actual_region(desired_region)
      _ -> actual_region("oss-cn-hangzhou")
    end
  end

  defp actual_region(region), do: URI.parse("https://" <> region <> ".aliyuncs.com")

  def bucket do
    uri          = uri()
    desired_host = Config.default() |> Map.get(:bucket) |> Kernel.<>(".") |> Kernel.<>(uri.host)
    Map.put(uri, :host, desired_host)
  end
end
