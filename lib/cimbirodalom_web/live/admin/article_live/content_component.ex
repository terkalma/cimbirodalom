defmodule CimbirodalomWeb.Admin.ArticleLive.ContentComponent do
  alias Cimbirodalom.Articles.Document
  use CimbirodalomWeb, :admin_live_component
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div id={@editor_id <> "-comm"} phx-hook="EditorComm" data-owner={@myself}></div>
      <article
        id={@editor_id}
        class={[
          "px-10",
          "h-full",
          "min-h-[100vh]"
        ]}
        data-document={Jason.encode! @document}
        phx-update="ignore"
        phx-mounted={JS.dispatch("phx:editor:init", detail: %{id: @editor_id})}
      >
      </article>
    </div>
    """
  end

  @impl true
  def update(%{content_id: content_id, article_id: article_id}, socket) do
    document = Document.retrieve(content_id)

    Logger.info("Document: #{inspect(document)}")

    {:ok,
     socket
     |> assign(:editor_id, "editor-" <> Integer.to_string(article_id))
     |> assign(:content_id, content_id)
     |> assign(:document, document)}
  end

  @impl true
  def handle_event("phx:content:updated", %{"changes" => %{"ops" => ops}}, socket) do
    {:noreply, socket |> assign(:document, Document.update(socket.assigns.content_id, ops))}
  end
end
