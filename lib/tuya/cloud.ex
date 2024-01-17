defmodule Tuya.Cloud do
  @moduledoc """
  Functions to connect to Tuya Cloud and control devices.  There's a lot of stuff to
  do on the Tuya side for this to work, be advised.
  """

  alias Req.Request

  @tuya_cloud_secret Application.compile_env(:hi_pi, :tuya_cloud_secret)
  @tuya_cloud_client_id Application.compile_env(:hi_pi, :tuya_cloud_client_id)
  @tuya_cloud_base_url Application.compile_env(:hi_pi, :tuya_cloud_base_url)

  def request(url, method \\ :get, token \\ "") do
    Req.new(base_url: @tuya_cloud_base_url, url: url, method: method)
    |> Request.put_private(:token, token)
    |> Request.append_request_steps(tuya: &tuya_step/1)
  end

  def tuya_step(request) do
    request
    |> Request.put_private(:timestamp, timestamp())
    |> Request.put_private(:nonce, nonce())
    |> add_headers()
  end

  def add_headers(request) do
    request
    |> Request.put_headers([
      {"client_id", @tuya_cloud_client_id},
      {"sign", hash(request)},
      {"sign_method", "HMAC-SHA256"},
      {"t", Request.get_private(request, :timestamp)},
      {"nonce", Request.get_private(request, :nonce)},
      {"access_token", Request.get_private(request, :token)},
      {"lang", "en"}
    ])
  end

  def hash(request) do
    digest(
      Request.get_private(request, :timestamp),
      Request.get_private(request, :nonce),
      Request.get_private(request, :token) || "",
      string_to_sign(request)
    )
  end

  defp string_to_sign(request) do
    IO.inspect(request.url, label: "URL")
    [
      request.method |> to_string |> String.upcase(),
      :crypto.hash(:sha256, request.body || "") |> Base.encode16(case: :lower),
      "",
      url_for_hash(request.url)
    ]
    |> Enum.join("\n")
  end

  defp digest(timestamp, nonce, token, str) do
    :crypto.mac(
      :hmac,
      :sha256,
      @tuya_cloud_secret,
      @tuya_cloud_client_id <> token <> timestamp <> nonce <> str
    )
    |> Base.encode16(case: :upper)
  end

  defp timestamp() do
    (DateTime.utc_now()
     |> DateTime.to_unix()
     |> to_string()) <> "000"
  end

  defp nonce() do
    "123"
  end

  defp url_for_hash(%URI{path: path, query: nil}) do
    path
  end
  defp url_for_hash(%URI{path: path, query: query}) do
    # Tuya wants the path only, and the query terms alphabetized by key (ugh)
    sorted_query =
      URI.decode_query(query)
      |> Enum.sort()
      |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
      |> Enum.join("&")

    # Concatenate path and sorted query, if any
    "#{path}?#{sorted_query}"
  end
end
