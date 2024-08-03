defmodule CimbirodalomWeb.Admin.ArticleLive.Edit do
  use CimbirodalomWeb, :admin_live_view

  alias Cimbirodalom.Articles

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do

    article = Articles.get_article!(id)
    content_id = Articles.get_content_id_by_article(id)
    Cimbirodalom.Articles.Document.init(content_id)

    socket
    |> assign(:page_title, "Edit Article")
    |> assign(:html_id, "article-" <> Integer.to_string(article.id))
    |> assign(:article_id, article.id)
    |> assign(:title, article.title)
    |> assign(:subtitle, article.subtitle)
    |> assign(:content_id, content_id)
  end
end
