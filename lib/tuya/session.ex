defmodule Tuya.Session do
  use GenServer

  alias Tuya.Cloud
  alias Req.Request

  # client side
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  # Brutal hard-coding for my switch
  def control_pge(on \\ true) do
    GenServer.call(__MODULE__, {:control_pge, on})
  end

  # server_side

  def init(state) do
    #let's just wait a bit before calling network
    Process.send_after(self(), :run_detection, 10_000)
    {:ok, state}
  end

  def handle_info(:run_detection, state) do
    state = %{token: get_token()}

    # Toggle the PGE device to trigger rising edge
    Process.send_after(self(), {:control_pge, false}, 3_000)
    Process.send_after(self(), {:control_pge, true}, 6_000)
    {:noreply, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end



  def handle_info({:control_pge, on}, state) do
    device_id = "eb03aa9cbdda9488f0jy9h"

    Cloud.request("/v1.0/devices/#{device_id}/commands", :post, state.token)
    |> Req.update(
      body:
        Jason.encode_to_iodata!(%{
          commands: [
            %{code: "switch_1", value: on},
            %{code: "countdown_1", value: 0},
            %{code: "relay_status", value: "last"},
            %{code: "light_mode", value: "relay"},
            %{code: "child_lock", value: false},
            %{code: "cycle_time", value: "0"},
            %{code: "random_time", value: "0"},
            %{code: "switch_inching", value: "0"}
          ]
        })
    )
    |> Request.run_request()
    |> IO.inspect()

    {:noreply, state}
  end

  defp get_token() do
    Cloud.request("/v1.0/token?grant_type=1")
    |> Request.run_request()
    |> result()
    |> IO.inspect()
    |> Map.get("access_token")
  end

  defp result({_, %Req.Response{body: body}}) do
    # TODO: handle/log errors
    body["result"]
  end
end
