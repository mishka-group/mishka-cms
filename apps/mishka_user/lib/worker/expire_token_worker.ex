defmodule MishkaUser.Worker.ExpireTokenWorker do
  use Oban.Worker, queue: :expire_token, max_attempts: 1
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.warn("Try to delete expired token")
    MishkaUser.Token.TokenManagemnt.delete_expire_token()
    MishkaUser.Token.UserToken.delete_expire_token()
    :ok
  end
end
