defmodule B2.API do

  def get(url, query \\ [], header \\ nil) do
    HTTPoison.start
    query = B2.Utils.encode_query(query)

    unless String.length(query) == 0 do
      url = "#{url}?#{query}"
    end

    unless header do
      header = B2.auth_header
    end

    HTTPoison.get!(url, header)
    |> handle_response
  end

  def post(url, req_body) do
    HTTPoison.start

    body = Poison.encode!(req_body)

    HTTPoison.post!(url, body, B2.auth_header)
    |> handle_response
  end

  def upload(url, body, header, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 4000)
    HTTPoison.start
    HTTPoison.post!(url, {:file, body}, header, timeout: timeout)
    |> handle_response
  end

  def delete(url) do
    HTTPoison.start
    HTTPoison.delete!(url, B2.auth_header)
    |> handle_response
  end

  defp handle_response(%HTTPoison.Response{body: body, status_code: code}) when code in 200..299 do
    {:ok, Poison.decode!(body)}
  end

  defp handle_response(%HTTPoison.Response{body: "", status_code: code}) do
    {:error, %{"code" => code}}
  end
  defp handle_response(%HTTPoison.Response{body: body, status_code: _}) do
    {:error, Poison.decode!(body)}
  end

end
