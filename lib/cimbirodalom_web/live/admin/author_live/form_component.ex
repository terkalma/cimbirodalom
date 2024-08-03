defmodule CimbirodalomWeb.Admin.AuthorLive.FormComponent do
  use CimbirodalomWeb, :admin_live_component

  require Logger
  alias Cimbirodalom.Authors

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="author-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div class="flex flex-col gap-8">
            <.input field={@form[:name]} type="text" label="Name" />
            <.input field={@form[:description]} type="textarea" rows={10} label="Description" />
            <input name="author[image_data]" id="author_image_data" type="hidden" />
          </div>
          <div class="flex flex-col gap-8" phx-drop-target={@uploads.avatar.ref}>
            <.file_input label="Image" image={@uploads.avatar} />

            <div class="w-72 h-72 mx-auto">
              <%= if length(@uploads.avatar.entries) > 0 do %>
                <%= for entry <- @uploads.avatar.entries do %>
                  <article class="upload-entry w-full h-full">
                    <div
                      id="author-movable"
                      class="relative bg-slate-100 p-[16px] rounded-t-lg"
                      phx-hook="AuthorImage"
                    >
                      <div
                        data-phx-update="ignore"
                        id="author-edge-handler"
                        class="rounded-full w-[16px] h-[16px] hover:w-[20px] hover:h-[20px] bg-rose-500 absolute z-10 cursor-move"
                      >
                      </div>
                      <div
                        data-phx-update="ignore"
                        id="author-center-handler"
                        class="rounded-full w-[16px] h-[16px] hover:w-[20px] hover:h-[20px] bg-rose-500 absolute z-10 cursor-move"
                      >
                      </div>
                      <.live_img_preview entry={entry} />
                    </div>
                    <%!-- entry.progress will update automatically for in-flight entries --%>
                    <progress value={entry.progress} max="100" class="w-full">
                      <%= entry.progress %>%
                    </progress>
                    <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                    <%= for err <- upload_errors(@uploads.avatar, entry) do %>
                      <p class="text-rose-600 mx-auto text-sm">
                        <%= upload_error_to_string(err) %>
                      </p>
                    <% end %>
                  </article>
                <% end %>
              <% else %>
                <%= if @thumb_img do %>
                  <img src={@thumb_img} class="w-full h-full rounded-full" />
                <% else %>
                  <div class="w-full h-full bg-slate-200 rounded-full"></div>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving..." class="w-1/2 mx-auto mt-4">Save Author</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:title, "New Author")
     |> allow_upload(:avatar, accept: :any, max_entries: 1, max_size: 10_000_000)}
  end

  @impl true
  def update(%{author: author} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:thumb_img, Authors.image_url(author, "medium"))
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

  defp extract_image_config(socket, author_params) do
    {crop_info, author_params} = Map.pop(author_params, "image_data")
    uploaded_entries = consume_uploaded_entries(socket, :avatar, fn %{path: image_path}, %{client_type: client_type} ->
      {:postpone, {image_path, client_type}}
    end)

    image_config = Authors.Image.new crop_info: crop_info, uploaded_entries: uploaded_entries

    {author_params, image_config}
  end

  defp save_author(socket, :edit, author_params) do
    {author_params, image_config} = extract_image_config(socket, author_params)

    case Authors.update_author(socket.assigns.author, author_params) do
      {:ok, author} ->
        process_images(
          socket,
          author,
          image_config,
          "Author updated successfully"
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        consume_uploaded_entries(socket, :avatar, fn _, _ -> {:ok, nil} end)
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_author(socket, :new, author_params) do
    {author_params, image_config} = extract_image_config(socket, author_params)
    case Authors.create_author(author_params) do
      {:ok, author} ->
        process_images(
          socket,
          author,
          image_config,
          "Author created successfully"
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        consume_uploaded_entries(socket, :avatar, fn _, _ -> {:ok, nil} end)
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp process_images(socket, author, image_config, success_message) do
    case Authors.process_images(author, image_config) do
      {:ok, image_paths} ->
        notify_parent({:saved, author, image_paths})
        consume_uploaded_entries(socket, :avatar, fn _, _ -> {:ok, nil} end)

        {:noreply,
         socket
         |> put_flash(:info, success_message)
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
  defp upload_error_to_string(:too_large), do: "Image too large, should be smaller than 10MB"
  defp upload_error_to_string(:too_many_files), do: "You have selected too many files"
  defp upload_error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
