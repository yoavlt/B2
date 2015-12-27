defmodule B2.AccountStore do

  @moduledoc """
  Cache application token.
  """

  use GenServer

  @unauthorized_message "warning: Failure to authorize " <>
    "your account. Please ensure correct B2 Cloud " <>
    "Storage application key and account id."

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    GenServer.cast(__MODULE__, :authorize)
    {:ok, %{"initialized" => false}}
  end

  @doc """
  fetch application token.
  """
  def application_token do
    GenServer.call(__MODULE__, :get_token)
  end

  @doc """
  fetch api url
  """
  def api_url do
    GenServer.call(__MODULE__, :get_api_url)
  end

  ## Callback
  def handle_cast(:authorize, %{"initialized" => false} = state) do
    case B2.Accounts.authorize do
      {:ok, result} ->
        state = Map.merge(%{"initialized" => true}, result)
        {:noreply, state}
      _ ->
        IO.write :stderr, @unauthorized_message
        {:noreply, state}
    end
  end

  def handle_call(:get_token, _from, %{"token" => token} = state) do
    {:reply, token, state}
  end

  def handle_call(:get_token, _from, state) do
    on_authorized_call(state, fn %{"authorizationToken" => token} ->
      token
    end)
  end

  def handle_call(:get_api_url, _from, state) do
    on_authorized_call(state, fn %{"apiUrl" => api_url} ->
      api_url
    end)
  end

  defp on_authorized_call(state, on_ok) do
    case B2.Accounts.authorize do
      {:ok, result} ->
        state = Map.merge(%{"initialized" => true}, result)
        {:reply, on_ok.(result), state}
      _ ->
        IO.write :stderr, @unauthorized_message
        {:reply, :error, state}
    end
  end
end
