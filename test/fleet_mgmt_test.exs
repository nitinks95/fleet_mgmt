defmodule FleetMgmtTest do
  use ExUnit.Case
  doctest FleetMgmt

  test "greets the world" do
    assert FleetMgmt.hello() == :world
  end
end
