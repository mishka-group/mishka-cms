defmodule MishkaUser.Worker.ExpireTokenWorker do
  use Oban.Worker, queue: :expire_token, max_attempts: 1
  require Logger

  @spec perform(Oban.Job.t()) :: :ok
  def perform(%Oban.Job{}) do
    IO.inspect("this is what is it")
    :ok
  end
end
