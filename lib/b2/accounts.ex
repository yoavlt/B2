defmodule B2.Accounts do

  @moduledoc """
  Account of B2 Cloud Storage manipulation module.
  """

  defp authorize_url, do: B2.endpoint <>
    "/v1/b2_authorize_account"

  @doc """
  Used to log in to the B2 API. Returns an authorization token that can be used for account-level operations, and a URL that should be used as the base URL for subsequent API calls.

  ## Example
  iex) B2.Accounts.authorize
  {:ok,
   %{"accountId" => "your_account_id",
     "apiUrl" => "https://api001.backblaze.com",
     "authorizationToken" => "authorization-token",
     "downloadUrl" => "https://f001.backblaze.com"}}
  """
  def authorize, do:
    B2.API.get(authorize_url, [], B2.basic_auth_header)

end
