defmodule MishkaApiWeb.Router do
  use MishkaApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MishkaApiWeb do
    pipe_through :api

  end

  scope "/api/auth/v1", MishkaApiWeb do
    pipe_through :api
    post "/register", AuthController, :rgister
    post "/login", AuthController, :login
  end


  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MishkaApiWeb.Telemetry
    end
  end
end
