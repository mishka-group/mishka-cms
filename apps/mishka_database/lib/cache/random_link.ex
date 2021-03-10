defmodule MishkaDatabase.Cache.RandomLink do
  use GenServer
  require Logger

  @reject_expired_code :timer.seconds(360)
  @alphabet Enum.concat([?0..?9, ?A..?Z, ?a..?z])


  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def save(email, params \\ %{}) do
    GenServer.call(__MODULE__, {:push, email, params})
  end


  def get_code_with_code(code) do
    GenServer.call(__MODULE__, {:get_code_with_code, code})
  end


  def get_codes_with_email(email) do
    GenServer.call(__MODULE__, {:get_codes_with_email, email})
  end

  def delete_code_with_code(code) do
    GenServer.cast(__MODULE__, {:delete_code_with_code, code})
  end

  def delete_codes_with_email(email) do
    GenServer.cast(__MODULE__, {:delete_codes_with_email, email})
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end


  @impl true
  def init(state) do
    Logger.info("OTP RandomLink server was started")
    {:ok, state, {:continue, :start_reject_link}}
  end


  @impl true
  def handle_continue(:start_reject_link, state) do
    Process.send_after(__MODULE__, :reject_expired_code, @reject_expired_code)
    {:noreply, state}
  end


  @impl true
  def handle_call({:get_code_with_code, code}, _from, state) do
    system_time = System.system_time(:second)

    random_code = Enum.find(state, fn x -> x.code == code end)
    |> case do
      nil -> {:error, :get_code_with_code, :no_data}

      data when data.code == code and data.exp >= system_time ->
        {:ok, :get_code_with_code, data.code, data.email, data.params}

      data when data.code == code and data.exp <= system_time ->
        {:error, :get_code_with_code, :time}

      _ -> {:error, :get_code_with_code, :different_code}
    end

    {:reply, [random_code], state}
  end


  @impl true
  def handle_call({:get_codes_with_email, email}, _from, state) do
    selected_state = state
    |> Enum.find(fn x -> x.email == email end)

    {:reply, selected_state, state}
  end


  @impl true
  def handle_call({:push, email, params}, _from, state) do
    exp_time = DateTime.utc_now() |> DateTime.add(600, :second) |> DateTime.to_unix()
    code = randstring()
    {:reply, code, state ++ [%{id: random_link_id(), email: email, code: "#{code}", params: params, exp: exp_time}]}
  end


  @impl true
  def handle_cast({:delete_code_with_code, code}, state) do
    new_state = state
    |> Enum.reject(fn x -> x.code == code end)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:delete_codes_with_email, email}, state) do
    new_state = state
    |> Enum.reject(fn x -> x.email == email end)
    {:noreply, new_state}
  end


  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("OTP RandomLink server was stoped and clean State")
    {:stop, :normal, stats}
  end


  @impl true
  def handle_info(:reject_expired_code,  state) do
    Logger.info("OTP Reject Expired Link Task server was started")
    new_state = state
    |> Enum.reject(fn x -> x.exp <= System.system_time(:second) end)
    Process.send_after(__MODULE__, :reject_expired_code, @reject_expired_code)
    {:noreply, new_state}
  end

  def randstring(count \\ 20) do
    :rand.seed(:exsplus, :os.timestamp())
    randome = Stream.repeatedly(&random_char_from_alphabet/0)
    |> Enum.take(count)
    |> List.to_string()

    "#{randome}#{String.split(Ecto.UUID.generate, "-") |> List.to_string}"
  end

  defp random_char_from_alphabet() do
    Enum.random(@alphabet)
  end

  def random_link_id(count \\ 10) do
    :crypto.strong_rand_bytes(count) |> Base.url_encode64(padding: false)
  end
end
