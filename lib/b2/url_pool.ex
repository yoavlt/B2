defmodule B2.UrlPool do
  @moduledoc """
  Upload URL Pool
  """

  alias B2.File
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Fetch specified bucket url.
  """
  def get_upload_url(bucket_id) do
    GenServer.call(__MODULE__, {:get_upload_url, bucket_id})
  end

  @doc """
  Cache a specified upload url.
  """
  def cache_bucket_url(bucket_id) do
    GenServer.cast(__MODULE__, {:cache_bucket_url, bucket_id})
  end

  ### Callbacks

  def handle_call({:get_upload_url, bucket_id}, _from, map) do
    {value, next} = Map.pop_lazy(map, bucket_id, fn ->
      File.upload_url(bucket_id)
    end)
    cache_bucket_url(bucket_id)
    {:reply, value, next}
  end

  def handle_cast({:cache_bucket_url, bucket_id}, map) do
    value = File.upload_url(bucket_id)
    {:noreply, Map.put(map, bucket_id, value)}
  end

end
