defmodule B2.Utils do
  @moduledoc false

  @doc """
  Encode request query
  """
  def encode_query(query) do
    Enum.map_join query, "&", fn x ->
      pair(x)
    end
  end

  defp pair({key, value}) do
    if Enumerable.impl_for(value) do
      pair(to_string(key), [], value)
    else
      param_name = key |> to_string |> URI.encode
      param_value = value |> to_string |> URI.encode

      "#{param_name}=#{param_value}"
    end
  end

  defp pair(root, parents, values) do
    Enum.map_join values, "&", fn {key, value} ->
      if Enumerable.impl_for(value) do
        pair(root, parents ++ [key], value)
      else
        build_key(root, parents ++ [key]) <> to_string(value)
      end
    end
  end

  defp build_key(root, parents) do
    path = Enum.map_join parents, "", fn x ->
      param = x |> to_string |> URI.encode
      "[#{param}]"
    end

    "#{root}#{path}="
  end

  @doc """
  FIXME: Required openssl
  """
  def sha1(file_path) do
    args = ["dgst", "-sha1", file_path]
    {res, 0} = System.cmd("openssl", args)
    String.split(res, "=") |> Enum.at(1) |> String.strip
  end

end
