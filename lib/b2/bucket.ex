defmodule B2.Bucket do
  @moduledoc """
  Bucket handler of B2 Cloud Storage.
  """

  defp create_bucket_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_create_bucket"
  defp delete_bucket_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_delete_bucket"
  defp list_bucket_url, 
    do: B2.api_endpoint <> "/b2api/v1/b2_list_buckets"
  defp update_bucket_url,
    do: B2.api_endpoint <> "/b2api/v1/b2_update_bucket"

  @doc """
  Buckets can be named. The name must be globally unique.
  No account can use a bucket with the same name.
  Buckets are assigned a unique bucketId
  which is used when uploading, downloading, or deleting files.

  * type: :app_public or :all_private

  ## Example
  iex> B2.Bucket.create :all_public, name: "example-name"
  {:ok,
  %{"accountId" => "123456789abc",
  "bucketId" => "123423546",
  "bucketName" => "example-name", "bucketType" => "allPublic"}}
  """
  def create(type, opts)
  def create(:all_public, opts) do
    B2.API.post create_bucket_url, %{
      bucketName: Keyword.fetch!(opts, :name),
      accountId: B2.account_id,
      bucketType: "allPublic"
    }
  end
  def create(:all_private, opts) do
    B2.API.post create_bucket_url, %{
      bucketName: Keyword.fetch!(opts, :name),
      accountId: B2.account_id,
      bucketType: "allPrivate"
    }
  end

  @doc """
  Lists buckets associated with an account,
  in alphabetical order by bucket ID.

  iex> B2.Bucket.list
   %{"buckets" => [%{"accountId" => "12345abcd",
     "bucketId" => "1234567890-iur9859437",
     "bucketName" => "example-name",
     "bucketType" => "allPublic"}]}
  """
  def list do
    B2.API.post list_bucket_url, %{
      "accountId" => B2.account_id
    }
  end

  @doc """
  Deletes the bucket specified.
  Only buckets that contain no version of any files can be deleted.

  iex> B2.Bucket.delete "123456789"
  {:ok, %{"accountId" => "123456789abc", "bucketId" => "123456789",
   "bucketName" => "example-name", "bucketType" => "allPublic"}}
  """
  def delete(bucket_id) do
    B2.API.post delete_bucket_url, %{
      "bucketId" => bucket_id,
      "accountId" => B2.account_id
    }
  end

  @doc """
  Modifies the bucketType of an existing bucket.
  Can be used to allow everyone to download
  the contents of the bucket without providing any authorization,
  or to prevent anyone from downloading the contents of the bucket
  without providing a bucket auth token.

  iex> B2.Bucket.update "123456789", type: :all_public
  {:ok,
  %{"accountId" => "123455414", "bucketId" => "123456789",
  "bucketName" => "example-name", "bucketType" => "allPublic"}}
  """
  def update(bucket_id, type)
  def update(bucket_id, :all_public) do
    B2.API.post update_bucket_url, %{
      "accountId" => B2.account_id,
      "bucketId" => bucket_id,
      "bucketType" => "allPublic"
    }
  end
  def update(bucket_id, :all_private) do
    B2.API.post update_bucket_url, %{
      "accountId" => B2.account_id,
      "bucketId" => bucket_id,
      "bucketType" => "allPrivate"
    }
  end

end
