defmodule CimbirodalomWeb.AdminController do
  use CimbirodalomWeb, :admin_controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def settings(conn, %{"dark_mode" => dark_mode}) do
    if conn.assigns[:current_admin] do
      json(conn |> put_session(:dark_mode, dark_mode), %{status: :ok})
    else
      json(conn, %{status: :nok})
    end
  end
end
