defmodule MishkaDatabase.Public.SettingAgent do
  use Agent
  alias MishkaDatabase.Public.Setting
  require Logger

  @spec start_link(list()) :: {:error, any} | {:ok, pid}
  def start_link(_state) do
    Logger.info("SettingAgent was started")
    Agent.start_link(fn -> start_setting() end, name: __MODULE__)
  end

  @spec get(atom()) :: map() | nil
  def get(section) do
    Agent.get(__MODULE__, fn state ->
      Enum.find(state, fn x -> x.section == section end)
    end)
  end

  @spec get_config(atom, String.t()) :: String.t() | nil
  def get_config(section, config) do
    case get(section) do
      nil -> nil
      record -> get_in(record.configs, [config])
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
    Setting.settings(filters: %{})
  end
end
