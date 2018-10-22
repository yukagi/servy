defmodule Servy.Handler do
  @moduledoc "Handles HTTP Requets"

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]
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
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv ) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end
  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    IO.puts "==============================="
    IO.puts "inside the bears new route function"

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
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)} 

    #{conv.resp_body}
    """
  end

end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request2 = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request3 = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request4 = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request5 = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request6 = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request7 = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request8 = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
request9 = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request10 = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request2)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request3)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request4)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request5)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request6)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request7)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request8)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request9)
IO.puts response

IO.puts("====================================")
response = Servy.Handler.handle(request10)
IO.puts response

