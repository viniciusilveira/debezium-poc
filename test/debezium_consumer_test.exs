defmodule DebeziumConsumerTest do
  use ExUnit.Case
  doctest DebeziumConsumer

  test "greets the world" do
    assert DebeziumConsumer.hello() == :world
  end
end
