defmodule B2 do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(B2.AccountStore, []),
      worker(B2.UrlPool, [])
    ]

    opts = [strategy: :one_for_one, name: B2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  B2 Cloud Storage Endpoint
  """
  def endpoint, do: "https://api.backblaze.com/b2api"

  @doc """
  B2 Cloud Storage API Endpoint
  """
  def api_endpoint, do: B2.AccountStore.api_url

  @doc """
  Get basic authorization header
  """
  def basic_auth_header do
    encoded = Base.encode64("#{account_id}:#{application_key}")
    %{"Authorization" => "Basic " <> encoded,
      "Content-Type" => "application/x-www-form-urlencoded"}
  end

  @doc """
  Get token based authorization header
  """
  def auth_header do
    token = B2.AccountStore.application_token
    %{"Authorization" => token,
      "Content-Type" => "application/x-www-form-urlencoded"}
  end

  defp config do
    Application.get_env(:b2, B2)
  end

  @doc """
  Get account id.
  """
  def account_id do
    config()[:account_id] ||
      System.get_env("B2_ACCOUNT_ID")
  end

  @doc """
  Get application key.
  """
  def application_key do
    config()[:application_key] ||
      System.get_env("B2_APPLICATION_KEY")
  end

end
