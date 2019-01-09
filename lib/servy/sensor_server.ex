defmodule Servy.SensorServer do
  @name :sensor_server

  use GenServer

  # TODO: Look into the reason for doing this internal module.
  # Is it common practice? Or is it just a stopgap/example?
  defmodule State do
    defstruct sensor_data: %{}, refresh_interval: :timer.minutes(60)
  end

  ## Client Interface ##

  def start_link(interval) do
    IO.puts "Starting the sensor server with #{interval} min refresh..."
    initial_state = %State{refresh_interval: interval}
    GenServer.start_link(__MODULE__, initial_state, name: @name)
  end

  def get_sensor_data do
    GenServer.call @name, :get_sensor_data
  end

  ## Server Callbacks ##
  def init(state) do
    initial_state = %{state | sensor_data: run_tasks_to_get_sensor_data() }
    # Send a message after a delay
    schedule_refresh(initial_state.refresh_interval)

    {:ok, initial_state}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :refresh, interval)
  end

  def handle_info(:refresh, state) do
    IO.puts "Refreshing the cache with #{state.refresh_interval} ms refresh rate..."
    new_state = %{state | sensor_data: run_tasks_to_get_sensor_data()}

    schedule_refresh(state.refresh_interval)

    {:noreply, new_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data..."
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots = 
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end


