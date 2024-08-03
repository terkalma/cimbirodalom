defmodule Cimbirodalom.Articles.Delta do
  use GenServer, restart: :temporary
  require Logger

  # Following:
  # https://hexdocs.pm/elixir/main/genservers.html#content
  # https://slab.com/blog/announcing-delta-for-elixir/

  def update(pid, change), do: GenServer.call(pid, {:update, change})
  def retrieve(pid), do: GenServer.call(pid, :retrieve)
  def reset(pid), do: GenServer.call(pid, :reset)

  def start_link(content_id: content_id) do
    GenServer.start_link(__MODULE__, content_id: content_id, delay_initialization: false)
  end

  def start_link(content_id: content_id, delay_initialization: delay_initialization) do
    GenServer.start_link(__MODULE__,
      content_id: content_id,
      delay_initialization: delay_initialization
    )
  end

  @impl true
  def init(content_id: content_id, delay_initialization: delay) do
    if delay do
      {:ok, %{content_id: content_id, fetched: false}}
    else
      {:ok, %{content_id: content_id, fetched: false}, {:continue, :fetch_content}}
    end
  end

  @impl true
  def handle_continue(:fetch_content, %{content_id: content_id}) do
    {:noreply, reset_state(%{content_id: content_id})}
  end

  @impl true
  def handle_call(:reset, _from, %{content_id: content_id}) do
    {:reply, :ok, reset_state(%{content_id: content_id})}
  end

  @impl true
  def handle_call(
        :retrieve,
        _from,
        %{version: version, contents: contents, inverted_changes: inverted_changes} = state
      ) do
    {:reply, %{version: version, contents: contents, inverted_changes: inverted_changes}, state}
  end

  @impl true
  def handle_call({:update, change}, _from, %{contents: contents, fetched: true} = state) do
    contents = Delta.compose(contents, change)
    {:reply, :ok, %{state | contents: contents}}

    inverted = Delta.invert(change, contents)

    state = %{
      version: state.version + 1,
      contents: Delta.compose(state.contents, change),
      inverted_changes: [inverted | state.inverted_changes],
      fetched: true,
      content_id: state.content_id
    }

    # GenServer.cast(self(), :persist)
    # TODO - this doers not have to sync
    Logger.info("Persisting state: #{inspect(state)}")
    Cimbirodalom.Articles.persist_document!(state)
    Logger.info("Finished updating internal state: #{inspect(state)}")
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:persist, state) do
    Logger.info("Persisting state: #{inspect(state)}")
    Cimbirodalom.Articles.persist_document!(state)
    {:noreply, state}
  end

  defp reset_state(%{content_id: content_id}) do
    %{json_content: state} = Cimbirodalom.Articles.get_content!(content_id)

    case state do
      %{"contents" => contents, "version" => version, "inverted_changes" => inverted_changes} ->
        %{
          version: version,
          contents: contents,
          inverted_changes: inverted_changes,
          fetched: true,
          content_id: content_id
        }

      %{"contents" => contents} ->
        %{
          version: 1,
          contents: contents,
          inverted_changes: [],
          fetched: true,
          content_id: content_id
        }

      _ ->
        %{
          version: 0,
          contents: [],
          inverted_changes: [],
          fetched: true,
          content_id: content_id
        }
    end
  end
end
