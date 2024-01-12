defmodule HiPiTest do
  use ExUnit.Case
  doctest HiPi

  test "greets the world" do
    assert HiPi.hello() == :world
  end
end
