defmodule MishkaDatabase.Cache.RandomCode do
  use GenServer
  require Logger

  @reject_expired_code :timer.seconds(1)

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def save(email, code) do
    start_expired_task()
    GenServer.cast(__MODULE__, {:push, email, code})
  end

  def get_user(email, code) do
    start_expired_task()
    GenServer.call(__MODULE__, {:get_user, email, code})
  end

  def delete_code(code, email) do
    start_expired_task()
    GenServer.cast(__MODULE__, {:delete_code, code, email})
  end

  def get_code_with_email(email) do
    start_expired_task()
    GenServer.call(__MODULE__, {:get_code_with_email, email})
  end

  def get_code_with_code(code) do
    start_expired_task()
    GenServer.call(__MODULE__, {:get_code_with_code, code})
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  @impl true
  def init(state) do
    Logger.info("OTP RandomCode server was started")
    {:ok, state}
  end

  @impl true
  def handle_call({:get_user, email, code}, _from, state) do
    system_time = System.system_time(:second)

    random_code =
      Enum.find(state, fn x -> x.email == email end)
      |> case do
        nil ->
          {:error, :get_user, :no_data}

        data when data.code == code and data.exp >= system_time ->
          {:ok, :get_user, data.code, data.email}

        data when data.code == code and data.exp <= system_time ->
          {:error, :get_user, :time}

        _ ->
          {:error, :get_user, :different_code}
      end

    {:reply, [random_code], state}
  end

  @impl true
  def handle_call({:get_code_with_email, email}, _from, state) do
    selected_state =
      state
      |> Enum.find(fn x -> x.email == email end)

    {:reply, selected_state, state}
  end

  @impl true
  def handle_call({:get_code_with_code, code}, _from, state) do
    selected_state =
      state
      |> Enum.find(fn x -> x.code == code end)

    {:reply, selected_state, state}
  end

  @impl true
  def handle_cast({:push, email, code}, state) do
    exp_time = DateTime.utc_now() |> DateTime.add(600, :second) |> DateTime.to_unix()

    state
    |> Enum.find(fn x -> x.email == email end)
    |> case do
      nil ->
        {:noreply, state ++ [%{email: email, code: "#{code}", exp: exp_time}]}

      data ->
        new_state =
          state
          |> Enum.reject(fn x -> x.email == data.email end)

        {:noreply, new_state ++ [%{email: email, code: "#{code}", exp: exp_time}]}
    end
  end

  @impl true
  def handle_cast({:delete_code, _code, email}, state) do
    new_state =
      state
      |> Enum.reject(fn x -> x.email == email end)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("OTP RandomCode server was stoped and clean State")
    {:stop, :normal, stats}
  end

  @impl true
  def handle_info(:reject_expired_code, state) do
    new_state =
      state
      |> Enum.reject(fn x -> x.exp <= System.system_time(:second) end)

    {:noreply, new_state}
  end

  def start_expired_task() do
    Process.send_after(__MODULE__, :reject_expired_code, @reject_expired_code)
  end
end
