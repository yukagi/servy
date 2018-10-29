# Erlang version
#server() ->
    #{ok, LSock} = gen_tcp:listen(5678, [binary, {packet, 0}, 
                                        #{active, false}]),
    #{ok, Sock} = gen_tcp:accept(LSock),
    #{ok, Bin} = do_recv(Sock, []),
    #ok = gen_tcp:close(Sock),
    #ok = gen_tcp:close(LSock),
    #Bin.
  
# Translated to Elixir. Replaced by what you see in the actual module.
  #def server do
    #{:ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0, active: false])
    #{:ok, sock} = :gen_tcp.accept(lsock)
    #{:ok, bin} = :gen_tcp.recv(sock, 0)
    ## send response and loop back to wait for another request
    #:ok = :gen_tcp.close(sock)
    #:ok = :gen_tcp.close(lsock)

    #bin
  #end

defmodule Servy.HttpServer do
  @moduledoc """
  Starts the server on the given `port` of localhost.
  """
  # Creates a socket to listen for client connections.
  # `listen_socket` is bound to the listening socket.
  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    # Socket options (don't worry about these details):
    # `:binary` - open the socket in "binary" mode and deliver data as binaries
    # `packet: :raw` - deliver the entire binary without doing any packet handling
    # `active: false` - receive data when we're ready by calling `:gen_tcp.recv/2`
    # `reuseaddr: true` - allows reusing the address if the listener crashes

    IO.puts "\n Listening for connection requests on port #{port}... \n"

    accept_loop(listen_socket)
  end

  @doc """
  Accepts client connections on the `listen_socket`. 
  """
  def accept_loop(listen_socket) do
    IO.puts "waiting to accept a client connection...\n"

    # Suspends (blocks) and waits for a client connection. When a connection
    # is accepted, `client_socket` is bound to a new client socket.
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts "Connection accepted~!\n"

    pid = spawn(fn -> serve(client_socket) end)
    :ok = :gen_tcp.controlling_process(client_socket, pid)

    accept_loop(listen_socket)
  end

  @doc """
  Receives the request on the `client_socket` and
  sends a response back over the same socket.
  """
  def serve(client_socket) do
    IO.puts "#{inspect self()}: Working on it!"
    client_socket
    |> read_request
    |> Servy.Handler.handle
    |> write_response(client_socket)
  end

  @doc """
  Receives a request on the `client_socket`.
  """
  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0) # 0 means all available bytes

    IO.puts "Received Requet:\n"
    IO.puts request

    request
  end

  @doc """
  Returns a generic HTTP Response.
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  @doc """
  Sends the `response` over the `client_socket`.
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts "Sent Response:\n"
    IO.puts response
    
    # Closes the client socket, ending the connection
    # Does not close the listen socket!
    :gen_tcp.close(client_socket)
  end

  def client do
    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """
    host = 'localhost' #% to make it runnable on one machine
    {:ok, sock} = :gen_tcp.connect(host, 4000, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(sock, request)
    {:ok, response} = :gen_tcp.recv(sock, 0)

    :ok = :gen_tcp.close(sock)
    response
  end
end

