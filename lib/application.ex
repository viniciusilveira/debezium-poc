defmodule DebeziumConsumer.Application do
  # read more about Elixir's Application module here: https://hexdocs.pm/elixir/Application.html
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # calls to start Kaffe's Consumer module
      %{
        id: Kaffe.GroupMemberSupervisor,
        start: {Kaffe.GroupMemberSupervisor, :start_link, []},
        type: :supervisor
      }
      # worker(Kaffe.Consumer, [])
    ]

    opts = [strategy: :one_for_one, name: DebeziumConsumer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
