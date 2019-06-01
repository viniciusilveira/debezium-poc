defmodule DebeziumConsumer do
  @moduledoc """
  Documentation for DebeziumConsumer.
  """

  def handle_messages(messages) do
    IO.inspect(messages)
    require IEx; IEx.pry


    for %{key: key, value: value} = message <- messages do
      IO.inspect(message)
      IO.puts("#{key}: #{value}")
    end

    # Important!
    :ok
  end
end
