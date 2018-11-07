defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "server caches only the 3 most recent pledges" do
    # Why doesn't this work... :thinking:
    #spawn(PledgeServer, :start, [])
    PledgeServer.start

    pledges = [
      {"larry", 10},
      {"curly", 20},
      {"moe", 30},
      {"shep", 40},
      {"daisy", 50}
    ]

    expected_recent = [
      {"daisy", 50},
      {"shep", 40},
      {"moe", 30}
    ]

    pledges
    |> Enum.map(fn(pledge) -> PledgeServer.create_pledge(elem(pledge, 0), elem(pledge, 1)) end)

    assert PledgeServer.recent_pledges == expected_recent
    assert PledgeServer.total_pledged == 120
  end
end

