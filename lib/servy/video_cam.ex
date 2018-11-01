defmodule Servy.VideoCam do
  @doc """
  Simulates sending a request to an external API
  to get a snapshot image from a video camera.
  """
  def get_snapshot(camera_name) do
    # CODE GOES HERE TO SEND A REQUEST TO THE EXTERNAL API

    # Sleep for 1 second to simulate that the API can be slow:
    :timer.sleep(1000)

    # Example response returned from the API:
    "#{camera_name}-snapshot.jpg"
  end
end

defmodule Servy.ImageApi do
  def get(id) do
    api_url(id)
    |> HTTPoison.get 
    |> parse_response
  end

  def api_url(id) do
    "https://api.myjson.com/bins/#{URI.encode(id)}"
  end

  def parse_response({:ok, %{status_code: 200, body: body}}) do
    url = body
    |> Poison.Parser.parse!(%{})
    |> get_in(["image", "image_url"])
    {:ok, url}
  end
  def parse_response({:ok, %{status_code: _code, body: body}}) do
    message = body
    |> Poison.Parser.parse!(%{})
    |> get_in(["message"])

    {:error, message}
  end
  def parse_response({:error, %{reason: reason}}) do
    {:error, reason}
  end
end
