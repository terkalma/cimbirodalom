defmodule CimbirodalomWeb.Admin.ArticleLive.Index do
  use CimbirodalomWeb, :admin_live_view

  alias Cimbirodalom.Articles
  alias Cimbirodalom.Articles.Article

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :articles, Articles.list_articles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Article")
    |> assign(:article, Articles.get_article!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Article")
    |> assign(:article, %Article{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Articles")
    |> assign(:article, nil)
  end

  @impl true
  def handle_info({CimbirodalomWeb.Admin.ArticleLive.FormComponent, {:saved, article}}, socket) do
    {:noreply, stream_insert(socket, :articles, article)}
  end

  @impl true
  def handle_info({CimbirodalomWeb.Admin.ArticleLive.FormComponent, {:created, article}}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/articles/#{article.id}/edit")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO should be using the archive function, but that requires a partial index
    article = Articles.get_article!(id)
    {:ok, _} = Articles.delete_article(article)

    {:noreply, stream_delete(socket, :articles, article)}
  end
end
