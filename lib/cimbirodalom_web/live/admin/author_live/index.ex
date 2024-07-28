defmodule CimbirodalomWeb.Admin.AuthorLive.Index do
  use CimbirodalomWeb, :admin_live_view

  alias Cimbirodalom.Authors
  alias Cimbirodalom.Authors.Author
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket |> assign(upload_tasks: %{}), :authors, Authors.list_authors())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Author")
    |> assign(:author, Authors.get_author!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Author")
    |> assign(:author, %Author{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Authors")
    |> assign(:author, nil)
  end

  @impl true
  def handle_info(
        {CimbirodalomWeb.Admin.AuthorLive.FormComponent, {:saved, author, image_paths}},
        socket
      )
      when image_paths == %{} do
    {:noreply, stream_insert(socket, :authors, author)}
  end

  @impl true
  def handle_info(
        {CimbirodalomWeb.Admin.AuthorLive.FormComponent, {:saved, author, image_paths}},
        socket
      ) do
    case Authors.lock_for_asset_update(author.id) do
      {true, ts} ->
        task =
          Task.Supervisor.async_nolink(
            Cimbirodalom.TaskSupervisor,
            Cimbirodalom.Authors,
            :upload_images,
            [author.id, image_paths],
            timeout: 10_000
          )

        Logger.info("Task started: author_id=#{author.id}, ref=#{inspect(task.ref)}, ts=#{ts}")
        tasks = Map.put(socket.assigns.upload_tasks, task.ref, {ts, author.id})
        Logger.info("Tasks: #{Kernel.inspect(tasks)}")
        {:noreply, stream_insert(socket |> assign(:upload_tasks, tasks), :authors, author)}

      {false, _} ->
        Logger.info(
          "Task not started: author_id=#{author.id}, ts=#{author.locked_for_asset_update_at}"
        )

        {:noreply, stream_insert(socket, :authors, author)}
    end
  end

  @impl true
  def handle_info(
        {ref, {:upload_task, author_id, uploaded_paths}},
        socket
      ) do
    Process.demonitor(ref, [:flush])
    {task_data, tasks} = Map.pop(socket.assigns[:upload_tasks], ref)

    case task_data do
      {ts, original_author_id} ->
        Logger.info(
          "Task completed: author_id=#{author_id}, original_author_id=#{original_author_id}, ref=#{inspect(ref)}, ts=#{ts}"
        )

        Logger.info("Task result: #{inspect(uploaded_paths)}")
        Logger.info("Active tassks: #{Kernel.inspect(tasks)}")

        {_, author} = Authors.reset_asset_lock(author_id, uploaded_paths, ts)
        Logger.info("Updating author: #{inspect(author.img_data)}")

        {:noreply,
         stream_insert(socket |> assign(:upload_tasks, tasks), :authors, author)
         |> put_flash(:info, "Images uploaded for '#{author.name}'")}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, socket) do
    {task_data, tasks} = Map.pop(socket.assigns[:upload_tasks], ref)

    case task_data do
      {ts, author_id} ->
        Logger.info("Task completed: author_id=#{author_id}, ref=#{inspect(ref)}, ts=#{ts}")
        Logger.info("Active tassks: #{Kernel.inspect(tasks)}")
        {:noreply, socket |> assign(:upload_tasks, tasks)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    author = Authors.get_author!(id)
    {:ok, _} = Authors.delete_author(author)

    {:noreply, stream_delete(socket, :authors, author)}
  end

  @impl true
  def handle_event("start-editing", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/authors/#{id}/edit")}
  end
end
