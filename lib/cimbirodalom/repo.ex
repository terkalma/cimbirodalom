defmodule Cimbirodalom.Repo do
  use Ecto.Repo,
    otp_app: :cimbirodalom,
    adapter: Ecto.Adapters.Postgres
end
