defmodule Chatwebsocket.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChatwebsocketWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Chatwebsocket.PubSub},
      # Start the Endpoint (http/https)
      ChatwebsocketWeb.Endpoint,
      # Start a worker by calling: Chatwebsocket.Worker.start_link(arg)
      # {Chatwebsocket.Worker, arg}
      {Xandra, name: :kloenschnack_connection, nodes: ["creepytoast.ddns.net:9042"]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatwebsocket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChatwebsocketWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
