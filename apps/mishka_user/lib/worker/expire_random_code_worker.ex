defmodule MishkaUser.Worker.ExpireRandomCodeWorker do
  use Oban.Worker, queue: :expire_token, max_attempts: 1
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email}}) do
    Logger.warn("Try to delete expired random code")
    MishkaUser.Validation.RandomCode.delete_code(email)
    :ok
  end

  def delete_random_code_scheduled(email, time \\ DateTime.utc_now() |> DateTime.add(600, :second)) do
    %{email: email}
    |> MishkaUser.Worker.ExpireRandomCodeWorker.new(scheduled_at: time)
    |> Oban.insert()
  end
end
