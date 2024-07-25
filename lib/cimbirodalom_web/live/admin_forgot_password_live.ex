defmodule CimbirodalomWeb.AdminForgotPasswordLive do
  use CimbirodalomWeb, :admin_live_view

  alias Cimbirodalom.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md bg-white dark:bg-slate-800 p-10 rounded-lg shadow-md">
      <.header class="text-center">
        Forgot your password?
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"/admin/register"}>Register</.link>
        | <.link href={~p"/admin/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "admin"))}
  end

  def handle_event("send_email", %{"admin" => %{"email" => email}}, socket) do
    if admin = Accounts.get_admin_by_email(email) do
      Accounts.deliver_admin_reset_password_instructions(
        admin,
        &url(~p"/admin/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/admin/reset_password")}
  end
end
