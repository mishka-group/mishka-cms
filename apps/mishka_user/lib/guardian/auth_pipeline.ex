defmodule MishkaUser.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :mishka_user,
      module: MishkaUser.Guardian,
      error_handler: MishkaUser.AuthErrorHandler


  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true, allow_blank: true
end
