defmodule MishkaInstallerTest.State.PluginDatabaseTest do
  use ExUnit.Case, async: true
  doctest MishkaInstaller
  alias MishkaInstaller.Plugin

  @new_soft_plugin %MishkaInstaller.PluginState{
    name: "plugin_one",
    event: "event_one",
    priority: 1,
    status: :started,
    depend_type: :soft
  }

  # setup do
  #   :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  # end

  # setup tags do
  #   pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MishkaDatabase.Repo, shared: not tags[:async])
  #   on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  #   :ok
  # end

  setup_all _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MishkaDatabase.Repo, :auto)
    on_exit fn ->
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(MishkaDatabase.Repo, :auto)
      clean_db()
      :ok
    end

    [this_is: "is"]
  end

  describe "Happy | Plugin Database (▰˘◡˘▰)" do
    test "show plugins", %{this_is: _this_is} do
      clean_db()
      {:ok, :add, :plugin, record_info} = assert Plugin.create(Map.from_struct(@new_soft_plugin))
      1 = assert length(Plugin.plugins(event: record_info.event))
      1 = assert length(Plugin.plugins())
    end

    test "delete plugins dependencies without dependencies", %{this_is: _this_is} do
      clean_db()
      Enum.map(["joomla_login_plugin", "wordpress_login_plugin", "magento_login_plugin"], fn item ->
        Map.merge(@new_soft_plugin, %{name: item})
        |> Map.from_struct()
        |> Plugin.create()
      end)
      Plugin.delete_plugins("joomla_login_plugin")
      3 = assert length(Plugin.plugins())
    end

    test "delete plugins dependencies with dependencies which do not exist", %{this_is: _this_is} do
      clean_db()
      depends = ["joomla_login_plugin", "wordpress_login_plugin", "magento_login_plugin"]
      Map.merge(@new_soft_plugin, %{depend_type: :hard, depends: depends})
      |> Map.from_struct()
      |> Plugin.create()

      Plugin.delete_plugins("plugin_one")
      1 = assert length(Plugin.plugins())
    end

    test "delete plugins dependencies with dependencies which exist", %{this_is: _this_is} do
      clean_db()
      depends = ["joomla_login_plugin", "wordpress_login_plugin", "magento_login_plugin"]
      Enum.map(depends, fn item ->
        Map.merge(@new_soft_plugin, %{name: item, depend_type: :hard, depends: List.delete(depends, item)})
        |> Map.from_struct()
        |> Plugin.create()
      end)

      Enum.map(depends, fn item ->
        Map.merge(@new_soft_plugin, %{name: item, depend_type: :hard, depends: List.delete(depends, item)})
        |> MishkaInstaller.PluginState.push()
      end)

      Plugin.delete_plugins(List.first(depends))

      assert length(Plugin.plugins()) == 1
    end
  end

  # describe "UnHappy | Plugin Database ಠ╭╮ಠ" do

  # end

  defp clean_db() do
    MishkaInstaller.Plugin.plugins()
    |> Enum.map(fn x ->
      {:ok, :get_record_by_field, :plugin, repo_data} = MishkaInstaller.Plugin.show_by_name("#{x.name}")
      MishkaInstaller.Plugin.delete(repo_data.id)
    end)
  end
end
