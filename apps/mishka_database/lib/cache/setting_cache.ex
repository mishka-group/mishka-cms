defmodule MishkaDatabase.Cache.SettingCache do
  use GenServer
  require Logger

  alias MishkaDatabase.Public.Setting

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get(section) do
    GenServer.call(__MODULE__, {:get, section})
  end

  def get_all() do
    GenServer.call(__MODULE__, {:get, :all})
  end

  def get_config(section, config) do
    GenServer.call(__MODULE__, {:get, section, config})
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end


  @impl true
  def init(state) do
    Logger.info("OTP Cache server of setting was started")
    {:ok, state, {:continue, :start_storing_setting}}
  end


  @impl true
  def handle_continue(:start_storing_setting, _state) do
    # w8 for starting phoenix pubsub
    :timer.sleep(4000)
    create_basic_setting()
    {:noreply, Setting.settings(filters: %{})}
  end

  @impl true
  def handle_call({:get, :all}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get, section}, _from, state) do
    {:reply, get_data_with_section(section, state), state}
  end

  @impl true
  def handle_call({:get, section, config}, _from, state) do
    new_state = case get_data_with_section(section, state) do
      "" -> ""
      record ->
        if is_nil(get_in(record.configs, [config])), do: "", else: get_in(record.configs, [config])
    end
    {:reply, new_state, state}
  end


  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("OTP Cache server of setting was stoped and clean State")
    {:stop, :normal, stats}
  end

  defp get_data_with_section(section, state) do
    case Enum.find(state, fn x -> x.section == section end) do
      nil -> ""
      record -> record
    end
  end

  defp create_basic_setting() do
    Setting.create(%{
      section: "public",
      configs: %{
        "google_recaptcha_client_side_code" => "PLEASE PUT YOUR CODE",
        "google_recaptcha_server_side_code" => "PLEASE PUT YOUR CODE",
        "captcha_status" => "developer",
      }
    })
  end
end
