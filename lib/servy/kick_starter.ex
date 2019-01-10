defmodule Servy.KickStarter do
  use GenServer

  def start_link(_arg) do
    IO.puts "Starting the KickStarter..."
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts "HTTP Server crashed: (#{inspect reason})"
    server_pid = start_server()
    {:noreply, server_pid}
  end

  def get_server() do
    Process.whereis(:http_server)
  end

  defp start_server do
    IO.puts "Starting the HTTP Server..."
    port = Application.get_env(:servy, :port)
    server_pid = spawn_link(Servy.HttpServer, :start, [port])
    Process.register(server_pid, :http_server)

    server_pid 
  end
end
