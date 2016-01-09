defmodule B2.File do

  @moduledoc """
  Handle file module.
  """

  alias B2.UrlPool

  defp upload_url_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_get_upload_url"

  defp file_info_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_get_file_info"

  defp file_hide_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_hide_file"

  defp list_names_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_list_file_names"

  defp list_versions_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_list_file_versions"

  defp delete_file_version_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_delete_file_version"

  @doc """
  Deletes one version of a file from B2.

  iex> B2.File.delete_file_version("3_c123436...",
    "filename.txt")
    {:ok,
      %{"fileId" => "3_c123436...",
      "fileName" => "filename.txt"}}
  """
  def delete_file_version(file_id, file_name) do
    B2.API.post(delete_file_version_url, %{
      "fileName" => file_name,
      "fileId" => file_id
    })
  end

  @doc """
  Gets information about one file stored in B2.

  iex> B2.File.file_info("z_12345678abcdefg")

  %{"accountId" => "123456789abc",
    "bucketId" => "123423546",
    "contentLength" => 5,
    "contentSha1" => "eefd5bc2c547bf82b177b6259c13f7723dc876d9",
    "contentType" => "text/plain",
    "fileId" => "z_12345678abcdefg",
    "fileInfo" => %{}, "fileName" => "filename.txt"}}
  """
  def file_info(file_id), do:
    B2.API.post(file_info_url, %{"fileId" => file_id})

  @doc """
  Hides a file so that downloading by name
  will not find the file, but previous versions of the file
  are still stored. See File Versions about what it means
  to hide a file.

  iex> B2.File.hide_file("123456abcde", "filename.txt")
  {:ok,
    %{"action" => "hide",
    "fileId" => "3_abcdefg12346",
    "fileName" => "filename.txt", "size" => 0,
    "uploadTimestamp" => 1451226778001}}
  """
  def hide_file(bucket_id, file_name) do
    B2.API.post(file_hide_url, %{
      "bucketId" => bucket_id,
      "fileName" => file_name
    })
  end

  @doc """
  Lists the names of all files in a bucket,
  starting at a given name.

  iex> B2.File.list_names("1234567abcdefg")
  {:ok, %{"files" => [], "nextFileName" => nil}}
  """
  def list_names(bucket_id) do
    B2.API.post(list_names_url, %{
      "bucketId" => bucket_id
    })
  end

  @doc """
  Lists all of the versions of all of the files contained in one bucket, in alphabetical order by file name, and by reverse of date/time uploaded for versions of files with the same name.

  iex> B2.File.list_versions("1234567abcdefg")
  {:ok,
    %{"files" => [%{"action" => "hide",
    "fileId" => "4_fileIdjfkla94389143",
    "fileName" => "filename.txt", "size" => 0,
    "uploadTimestamp" => 1451226778000},
    %{"action" => "upload",
    "fileId" => "3_c12345667...",
    "fileName" => "filename.txt", "size" => 5,
    "uploadTimestamp" => 1451225229000}],
    "nextFileId" => nil, "nextFileName" => nil}}
  """
  def list_versions(bucket_id) do
    B2.API.post(list_versions_url, %{
      "bucketId" => bucket_id
    })
  end

  @doc """
  Upload file.

  iex> B2.File.upload("1234325325", "filename.txt", "text/plain", "/upload/path.txt")
  {:ok,
  %{"accountId" => "16c146893e8e",
  "bucketId" => "11163c91b426e829531e081e",
  "contentLength" => 5,
  "contentSha1" => "eefd5bc2c547bf82b177b6259c13f7723dc876d9",
  "contentType" => "text/plain",
  "fileId" => "1_c13974832947897894354_5843umfkdsaf_jkdfa",
  "fileInfo" => %{}, "fileName" => "filename.txt"}}
  """
  def upload(bucket_id, file_name, content_type, file_path, opts) do
    case UrlPool.get_upload_url(bucket_id) do
      {:ok, %{"authorizationToken" => token, "uploadUrl" => upload_url}} ->
        upload_file(token, upload_url, file_name, content_type, file_path, opts)
      _ ->
        {:error, :failure}
    end
  end

  def upload_file(authorization_token, upload_url, file_name, content_type, file_path, opts) do
    %File.Stat{size: size} = File.stat!(file_path)
    upload_file(authorization_token,
      upload_url, file_name, content_type, size, file_path, opts)
  end

  def upload_file(authorization_token, upload_url, file_name, content_type, content_length, file_path, opts) do
    header = Map.merge(B2.auth_header, %{
      "Authorization"  => authorization_token,
      "X-Bz-File-Name" => URI.encode(file_name),
      "Content-Type" => content_type,
      "X-Bz-Content-Sha1" => B2.Utils.sha1(file_path),
      "Content-Length" => content_length
    })
    B2.API.upload(upload_url, file_path, header, opts)
  end

  @doc """
  When you upload a file to B2, you must call
  b2_get_upload_url first to get the URL for uploading directly
  to the place where the file will be stored.

  ## Example

  iex> B2.File.upload_url "1234567abcdefg"
  {:ok,
  %{"authorizationToken" => "219374324324132",
  "bucketId" => "1234567abcdefg",
  "uploadUrl" => "https://pod-000-1009-01.backblaze.com/b2api/v1/b2_upload_file/1234567abcdefg/3478192432"}}
  """
  def upload_url(bucket_id), do:
    B2.API.post(upload_url_url, %{
      "bucketId" => bucket_id
    })

end
