defmodule DebeziumConsumer do
  @moduledoc """
  Documentation for DebeziumConsumer.
  """
  def handle_message(%{key: key, value: value} = message) do
    IO.inspect(message)
    IO.puts("#{key}: #{value}")
    # The handle_message function MUST return :ok
    :ok
  end
end
