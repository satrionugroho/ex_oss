defmodule ExOss.Bridge.Arc do
  @moduledoc false

  def put(definition, version, {file, scope} = resource) do
    folder = definition.storage_dir(version, resource)

    case upload(resource, version, folder) do
      %{filename: filename} -> {:ok, file.file_name}
      response -> {:error, response}
    end
  end

  def url(definition, version, {file, _scope} = resource, options \\ []) do
    expected_folder = definition.storage_dir(version, resource)
    folder = define_folder(expected_folder, version)
    file_name = Path.basename(Map.get(file, :file_name))
    actual_file = define_actual_file(folder, file_name)

    ExOss.get_object_link(actual_file)
  end

  defp upload({file, _scope}, vsn, folder), do: ExOss.put_object(file.path, folder: define_folder(folder, vsn), encrypted_name: false, filename: file.file_name)

  defp define_folder(folder, vsn) do
    case String.starts_with?(folder, "/") do
      true -> Kernel.to_string(vsn) <> folder
      false -> Kernel.to_string(vsn) <> "/" <> folder
    end
  end

  defp define_actual_file(folder, filename) do
    case String.ends_with?(folder, "/") do
      true -> folder
      _ -> folder <> "/"
    end |> Kernel.<>(filename)
  end
end
