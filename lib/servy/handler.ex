defmodule Servy.Handler do

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{ method: method, path: path, resp_body: "", status: nil }
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"} 
  end
  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/" <> id} 
  end
  def rewrite_path(conv), do: conv

  def track(%{status: 404, path: path} = conv) do
    IO.puts "WARNING: #{path} is on the loose."
    conv
  end
  def track(conv), do: conv

  def route(%{method: "GET", path: "/wildthings"} = conv ) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end
  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end
  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end
  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{conv | status: 403, resp_body: "Cannot delete da bears"}
  end
  def route(%{ path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)} 

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
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


