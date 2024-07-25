defmodule CimbirodalomWeb.Plugs.AdminSettings do
  import Plug.Conn

  def init(_opts), do: nil

  def call(conn, _opts) do
    assign(conn, :dark_mode, get_session(conn, :dark_mode))
  end
end
