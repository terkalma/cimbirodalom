defmodule CimbirodalomWeb.Admin.ArticleLive.Edit do
  use CimbirodalomWeb, :admin_live_view

  alias Cimbirodalom.Articles

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do

    article = Articles.get_article!(id)

    socket
    |> assign(:page_title, "Edit Article")
    |> assign(:title, article.title)
    |> assign(:subtitle, article.subtitle)
  end
end
