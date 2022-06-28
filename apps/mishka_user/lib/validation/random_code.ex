defmodule MishkaUser.Validation.RandomCode do
  use GenServer
  require Logger
  @ets_table :random_code_ets_state

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def save(email, code) do
    # TODO: send a job to a oban worker to delete expire this code
    exp_time = DateTime.utc_now() |> DateTime.add(600, :second) |> DateTime.to_unix()
    ETS.Set.put_new!(table(), {email, code, exp_time})
  end

  def get_all() do
    ETS.Set.to_list!(table())
  end

  def get_user(email, code) do
    system_time = System.system_time(:second)
    case ETS.Set.get(table(), email) do
      {:ok, {user_email, user_code, exp_time}} when user_code == code and exp_time >= system_time ->
        {:ok, :get_user, user_code, user_email}
      {:ok, {user_email, user_code, exp_time}} when user_code == code and exp_time <= system_time ->
        delete_code(user_email)
        {:error, :get_user, :time}
      _ -> {:error, :get_user, :different_code}
    end
  end

  def delete_code(email) do
    ETS.Set.delete(table(), email)
  end

  def get_code_with_email(email) do
    case ETS.Set.get!(table(), email) do
      nil -> nil
      {email, code, exp} -> %{email: email, code: code, exp: exp}
    end
  end

  def get_code_with_code(code) do
    pattern = [
      {{:"$1", :"$2", :"$3"}, [{:==, :"$2", code}], [:"$_"]}
    ]

    ETS.Set.select!(table(), pattern)
    |> List.first()
    |> case do
      nil -> nil
      {email, code, exp} -> %{email: email, code: code, exp: exp}
    end
  rescue
    _ -> nil
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  @impl true
  def init(_state) do
    Logger.info("OTP RandomCode server was started")
    table =
      ETS.Set.new!(
        name: @ets_table,
        protection: :public,
        read_concurrency: true,
        write_concurrency: true
      )

    {:ok, %{set: table}}
  end

  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("OTP RandomCode server was stoped and clean State")
    {:stop, :normal, stats}
  end

  defp table() do
    case ETS.Set.wrap_existing(@ets_table) do
      {:ok, set} -> set
      _ ->
        start_link([])
        table()
    end
  end
end
