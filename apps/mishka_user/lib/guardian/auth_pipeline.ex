defmodule MishkaUser.AuthPipeline do
	@claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :mishka_user, module: MishkaUser.Guardian, error_handler: MishkaUser.AuthErrorHandler

  # plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true


  # json VerifyHeader
  # plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  # plug Guardian.Plug.LoadResource, ensure: true, allow_blank: true
end
