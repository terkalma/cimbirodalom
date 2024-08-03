defmodule Cimbirodalom.Articles.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Cimbirodalom.Articles.Registry, name: Cimbirodalom.Articles.Registry},
      {DynamicSupervisor, name: Cimbirodalom.Articles.DeltaSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
