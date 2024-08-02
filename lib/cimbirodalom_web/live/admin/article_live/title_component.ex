defmodule CimbirodalomWeb.Admin.ArticleLive.TitleComponent do
  use CimbirodalomWeb, :admin_live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class={[
      "pt-10"
    ]}>
      <h1 class="mb-0 text-center"><%= @title %></h1>
      <h2 class="mt-0 text-center"><%= @subtitle %></h2>
    </div>
    """
  end

  @impl true
  def update(%{title: title, subtitle: subtitle}, socket) do
    {:ok, socket |> assign(:title, title) |> assign(:subtitle, subtitle)}
  end
end
