defmodule CimbirodalomWeb.Router do
  use CimbirodalomWeb, :router

  import CimbirodalomWeb.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CimbirodalomWeb.AppLayouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CimbirodalomWeb.AdminLayouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
    plug CimbirodalomWeb.Plugs.AdminSettings
  end

  pipeline :admin_api do
    plug :fetch_session
    plug :fetch_current_admin
    plug :accepts, ["json"]
  end

  scope "/", CimbirodalomWeb do
    pipe_through :browser
    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", CimbirodalomWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:cimbirodalom, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CimbirodalomWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/admin", CimbirodalomWeb do
    pipe_through [:admin_browser, :redirect_if_admin_is_authenticated]

    live_session :redirect_if_admin_is_authenticated,
      on_mount: [{CimbirodalomWeb.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/register", AdminRegistrationLive, :new
      live "/log_in", AdminLoginLive, :new
      live "/reset_password", AdminForgotPasswordLive, :new
      live "/reset_password/:token", AdminResetPasswordLive, :edit
    end

    post "/log_in", AdminSessionController, :create
  end

  scope "/admin", CimbirodalomWeb do
    pipe_through [:admin_api]

    post "/settings", AdminController, :settings
  end

  scope "/admin", CimbirodalomWeb do
    pipe_through [:admin_browser, :require_authenticated_admin]

    get "/", AdminController, :home

    live_session :require_authenticated_admin,
      on_mount: [{CimbirodalomWeb.AdminAuth, :ensure_authenticated}] do
      live "/settings", AdminSettingsLive, :edit
      live "/settings/confirm_email/:token", AdminSettingsLive, :confirm_email
    end
  end

  scope "/admin", CimbirodalomWeb do
    pipe_through [:admin_browser]

    delete "/log_out", AdminSessionController, :delete

    live_session :current_admin,
      on_mount: [{CimbirodalomWeb.AdminAuth, :mount_current_admin}] do
      live "/confirm/:token", AdminConfirmationLive, :edit
      live "/confirm", AdminConfirmationInstructionsLive, :new
    end
  end
end
