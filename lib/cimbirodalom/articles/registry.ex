defmodule Cimbirodalom.Articles.Registry do
  use GenServer
  alias Cimbirodalom.Articles.Delta

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    deltas = %{}
    references = %{}

    {:ok, {deltas, references}}
  end

  def find(pid, content_id) do
    GenServer.call(pid, {:find, content_id})
  end

  def create(pid, args) do
    GenServer.call(pid, {:create, args})
  end

  @impl true
  def handle_call({:find, content_id}, _from, {deltas, _} = state) do
    {:reply, Map.fetch(deltas, content_id), state}
  end


  @impl true
  def handle_call({:create, [content_id: content_id]}, from, {deltas, references}) do
    handle_call({:create, [content_id: content_id, delay_initialization: false]}, from, {deltas, references})
  end

  @impl true
  def handle_call({:create, [content_id: content_id, delay_initialization: delay]}, _from, {deltas, references}) do
    if Map.has_key?(deltas, content_id) do
      {:reply, Map.fetch(deltas, content_id), {deltas, references}}
    else
      {:ok, pid} = DynamicSupervisor.start_child(Cimbirodalom.Articles.DeltaSupervisor, {Delta, [content_id: content_id, delay_initialization: delay]})
      ref = Process.monitor(pid)
      {:reply, {:ok, pid}, {Map.put(deltas, content_id, pid), Map.put(references, ref, content_id)}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {deltas, references}) do
    {content_id, references} = Map.pop(references, ref)
    deltas = Map.delete(deltas, content_id)
    {:noreply, {deltas, references}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.warning("Unexpected message in Articles Registry: #{inspect(msg)}")
    {:noreply, state}
  end
end
