defmodule Servy.Handler do
  @moduledoc "Handles HTTP Requets"

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]
  import Servy.Conv, only: [put_content_length: 1]

  alias Servy.Conv
  alias Servy.BearController

  @doc """
  Transforms the request into a response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv ) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end
  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end
  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end
  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end
  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end
  def route(%{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, conv.params)
  end
  # name=Baloo&type=Brown
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end
  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end
  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end
  def route(%Conv{ path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  def format_response_headers(conv) do
    Enum.map(conv.resp_headers, fn {key, value} ->
    "#{key}: #{value}\r"
    end) |> Enum.sort |> Enum.reverse |> Enum.join("\n")
  end
end

