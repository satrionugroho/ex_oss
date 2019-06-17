defmodule ExOss do
  @moduledoc File.read! "README.md"

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: ExOss.Worker.start_link(arg)
      # {ExOss.Mime, []},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: :ex_oss]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Get binary of any object from bucket

  Object from bucket returned a binary from OSS, and it can be transfered to any kind of files, such as `png`, `jpg`, `pdf`, and many others,

  If not provided a credentials, returned 403 that means shoud verificate the user.

      iex> ExOss.get_object("file")
      %HTTPoison.Response{
        body: <<200, 324, 234, 123, 873, 324, 342, ...>>
        status_code: 200,
        ...
      }

  If errors the methods returned `HTTPoison.Error`
  """
  @spec get_object(name :: String.t(), options :: list()) :: map() | term()
  defdelegate get_object(name, options \\ []), to: ExOss.Downloader

  @doc """
  Get link of desired file

  Retrieve object link to accessible URL from browser

      iex> ExOss.get_object_link("file")
      https://your_bucket.oss-cn-hangzhou.aliyuncs.com/file?Signature=asdjbu121BDAasfd&Expires=152314121&OSSAccessKeyId=asdnk#48g

  """
  @spec get_object_link(name :: String.t(), options :: list()) :: String.t()
  defdelegate get_object_link(name, options \\ []), to: ExOss.Downloader

  @doc """
  Put any object to desired bucket

  Object can be transferred to bucket with `put_object/1` or `put_object/2`. Example:

      iex> ExOss.put_object("/path/to/your/file")
      %HTTPoison.Response{
        status_code: 200,
        filename: "file",
        ...
      }

      iex> ExOss.put_object("/path/to/your/file", encrypted_name: true)
      %HTTPoison.Response{
        status_code: 200,
        filename: "aasedt394jbDAjkgrf2oisndfiug",
        ...
      }

  If errors the methods returned `HTTPoison.Error`
  """
  @spec put_object(object :: String.t(), options :: list()) :: map() | term()
  defdelegate put_object(name, options \\ []), to: ExOss.Uploader

  @doc """
  Delete any document or file in a bucket

  Deletion file from bucket can be done with specify the filename and pass it to method

      iex> ExOss.delete_object("/path/to/your/file")
      %HTTPoison.Response{
        status_code: 200,
        filename: "file",
        ...
      }

  Error identified by status_code of HTTPoison response
  """
  @spec delete_object(name :: String.t(), options :: list()) :: map() | term()
  defdelegate delete_object(name, options \\ []), to: ExOss.Remover
end
