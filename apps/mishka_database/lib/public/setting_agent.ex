defmodule MishkaDatabase.Public.SettingAgent do
  use Agent
  alias MishkaDatabase.Public.Setting
  require Logger

  # TODO: change it with GenServer
  def start_link(state) do
    Logger.info("SettingAgent was started")
    Agent.start_link(fn -> state end, name: __MODULE__)
  end

  def update() do
    Agent.update(__MODULE__, fn _state -> start_setting() end)
  end

  @spec get(atom()) :: map() | nil
  def get(section) do
    if(get_all() == [], do: update())
    Agent.get(__MODULE__, fn state ->
      Enum.find(state, fn x -> x.section == section end)
    end)
    |> case do
      nil -> ""
      record -> record
    end
  end

  @spec get_config(atom, String.t()) :: String.t() | nil
  def get_config(section, config) do
    case get(section) do
      nil -> ""
      record ->
        if is_nil(get_in(record.configs, [config])), do: "", else: get_in(record.configs, [config])
    end
  end

  @spec get_all :: list()
  def get_all() do
    Agent.get(__MODULE__, & &1)
  end

  @spec stop :: :ok
  def stop() do
    Logger.info("SettingAgent was stoped")
    Agent.stop(__MODULE__)
  end

  defp start_setting() do
    case Setting.settings(filters: %{}) do
      [] ->
        create_basic_setting()
        start_setting()
      record ->
        if is_nil(Enum.find(record, fn x -> x.section == :public end)) do
          create_basic_setting()
          start_setting()
        else
          record
        end
    end
  end

  defp create_basic_setting() do
    case MishkaDatabase.Repo.start_link do
      {:error, {:already_started, _pid}} ->
        Setting.create(%{
          section: "public",
          configs: %{
            "google_recaptcha_client_side_code" => "PLEASE PUT YOUR CODE",
            "google_recaptcha_server_side_code" => "PLEASE PUT YOUR CODE",
            "captcha_status" => "developer",
          }
        })
      _ -> start_link([])
    end

  end
end
