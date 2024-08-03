defmodule Cimbirodalom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CimbirodalomWeb.Telemetry,
      Cimbirodalom.Repo,
      {DNSCluster, query: Application.get_env(:cimbirodalom, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Cimbirodalom.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Cimbirodalom.Finch},
      # Start a worker by calling: Cimbirodalom.Worker.start_link(arg)
      # {Cimbirodalom.Worker, arg},
      # Start to serve requests, typically the last entry
      CimbirodalomWeb.Endpoint,
      {Task.Supervisor, name: Cimbirodalom.TaskSupervisor},
      {Cimbirodalom.Articles.Supervisor, name: Cimbirodalom.Articles.Supervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cimbirodalom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CimbirodalomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
