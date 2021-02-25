defmodule Phxcrd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :gen_event.swap_handler(:alarm_handler, {:alarm_handler, :swap}, {Phxcrd.AlarmHandler, :ok})
    # :gen_event.add_handler(:alarm_handler, Phxcrd.AlarmHandler, []) |> IO.inspect

    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Phxcrd.Repo,
      # Start telemetry
      PhxcrdWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Phxcrd.PubSub},
      PhxcrdWeb.Presence,
      # Start the endpoint when the application starts
      PhxcrdWeb.Endpoint,
      Phxcrd.Mutex
      # Starts a worker by calling: Phxcrd.Worker.start_link(arg)
      # {Phxcrd.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phxcrd.Supervisor]
    # Old socket file must be deleted before starting again the app
    # File.rm("phxcrd.sock")
    val = Supervisor.start_link(children, opts)
    # You can also changeg the socket perms here
    # File.chmod("phxcrd.sock", 0o777)
    val
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhxcrdWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
