defmodule CimbirodalomWeb.Admin.AuthorLive.FormComponent do
  use CimbirodalomWeb, :admin_live_component

  alias Cimbirodalom.Authors

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage author records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="author-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:img_path]} type="text" label="Img path" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Author</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{author: author} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Authors.change_author(author))
     end)}
  end

  @impl true
  def handle_event("validate", %{"author" => author_params}, socket) do
    changeset = Authors.change_author(socket.assigns.author, author_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"author" => author_params}, socket) do
    save_author(socket, socket.assigns.action, author_params)
  end

  defp save_author(socket, :edit, author_params) do
    case Authors.update_author(socket.assigns.author, author_params) do
      {:ok, author} ->
        notify_parent({:saved, author})

        {:noreply,
         socket
         |> put_flash(:info, "Author updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_author(socket, :new, author_params) do
    case Authors.create_author(author_params) do
      {:ok, author} ->
        notify_parent({:saved, author})

        {:noreply,
         socket
         |> put_flash(:info, "Author created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
