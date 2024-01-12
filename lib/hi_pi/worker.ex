defmodule HiPi.Worker do
  use GenServer

  # client side
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def get_switch(pid) do
    GenServer.call(pid, :get_switch)
  end

  # server_side

  def init(state) do
    # Get a token?
    IO.inspect(state, label: "State")
    IO.inspect(self(), label: "PID")
    state = %{"PGE" => false}
    {:ok, state}
  end

  def handle_call(:get_switch, from, state) do
    IO.inspect(from)
    IO.inspect(state)
    {:reply, state, state}
  end


end
