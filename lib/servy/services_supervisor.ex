defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts "Starting the services supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # This is automatically called whe start_link gets called. And since we are passing :ok
  # as the argument, we are pattern matching on that here.
  #
  # This is where we will define the children it needs to start and supervise.
  def init(:ok) do
    children = [
      Servy.PledgeServer,
      {Servy.SensorServer, :timer.seconds(10)}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
  
end
