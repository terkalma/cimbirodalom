defmodule CimbirodalomWeb.Admin.ArticleLive.ContentComponent do
  use CimbirodalomWeb, :admin_live_component

  @impl true
  def render(assigns) do
    ~H"""
    <article id={@editor_id} class={[
      "px-10", "h-full", "min-h-[100vh]",
    ]} phx-mounted={JS.dispatch("phx:editor:init", detail: %{id: @editor_id})}>
      <p>Hello!</p>
    </article>
    """
  end

  @impl true
  def update(%{article_id: article_id}, socket) do
    {:ok, socket |> assign(:editor_id, "editor-" <> Integer.to_string(article_id))}
  end
end
