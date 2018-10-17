defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> log
    |> route
    |> format_response
  end

  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{ method: method, path: path, resp_body: "" }
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  def route(conv, "GET", "/wildthings") do
    %{ conv | resp_body: "Bears, Lions, Tigers" }
  end
  def route(conv, "GET", "/bears") do
    %{ conv | resp_body: "Teddy, Smokey, Paddington" }
  end
  def route(conv, "GET", "/bigfoot") do
    %{ conv | resp_body: "Bigfoot" }
  end

  def format_response(conv) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: "#{byte_size(conv.resp_body)}" 

    "#{conv.resp_body}"
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

response = Servy.Handler.handle(request)
IO.puts response

IO.puts("====================================")

response = Servy.Handler.handle(request2)
IO.puts response

IO.puts("====================================")

response = Servy.Handler.handle(request3)
IO.puts response
