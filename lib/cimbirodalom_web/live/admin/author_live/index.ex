defmodule CimbirodalomWeb.Admin.AuthorLive.Index do
  use CimbirodalomWeb, :admin_live_view

  alias Cimbirodalom.Authors
  alias Cimbirodalom.Authors.Author

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :authors, Authors.list_authors())}
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
  def handle_info({CimbirodalomWeb.Admin.AuthorLive.FormComponent, {:saved, author}}, socket) do
    {:noreply, stream_insert(socket, :authors, author)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    author = Authors.get_author!(id)
    {:ok, _} = Authors.delete_author(author)

    {:noreply, stream_delete(socket, :authors, author)}
  end
end
