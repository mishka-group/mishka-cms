defmodule MishkaInstallerTest.State.PluginDatabaseTest do
  use ExUnit.Case, async: true
  doctest MishkaInstaller
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

  @depends ["joomla_login_plugin", "wordpress_login_plugin", "magento_login_plugin"]
  @new_soft_plugin %MishkaInstaller.PluginState{
    name: "plugin_one",
    event: "event_one",
    priority: 1,
    status: :started,
    depend_type: :soft
  }

  @plugins [
    %MishkaInstaller.PluginState{
      name: "nested_plugin_one", event: "nested_event_one", priority: 100, status: :started, depend_type: :soft,
      depends: []
    },
    %MishkaInstaller.PluginState{
      name: "nested_plugin_two", event: "nested_event_one", priority: 100, status: :started, depend_type: :hard,
      depends: ["unnested_plugin_three"]
    },
    %MishkaInstaller.PluginState{
      name: "unnested_plugin_three", event: "nested_event_one", priority: 100, status: :started, depend_type: :hard,
      depends: ["nested_plugin_one"]
    },
    %MishkaInstaller.PluginState{
      name: "unnested_plugin_four", event: "nested_event_one", priority: 1, status: :started, depend_type: :soft,
      depends: []
    },
    %MishkaInstaller.PluginState{
      name: "unnested_plugin_five", event: "nested_event_one", priority: 1, status: :started, depend_type: :hard,
      depends: ["unnested_plugin_four"]
    }
  ]

  test "delete plugins dependencies with dependencies which do not exist", %{this_is: _this_is} do
    clean_db()
    Map.merge(@new_soft_plugin, %{depend_type: :hard, depends: @depends})
    |> Map.from_struct()
    |> MishkaInstaller.Plugin.create()

    MishkaInstaller.Hook.unregister(module: "plugin_one")
    assert length(MishkaInstaller.Plugin.plugins()) == 1
  end

  test "delete plugins dependencies with dependencies which exist", %{this_is: _this_is} do
    clean_db()
    Enum.map(@depends, fn item ->
      Map.merge(@new_soft_plugin, %{name: item, depend_type: :hard})
      |> Map.from_struct()
      |> MishkaInstaller.Plugin.create()
    end)

    Enum.map(@depends, fn item ->
      Map.merge(@new_soft_plugin, %{name: item, depend_type: :hard, depends: List.delete(@depends, item)})
      |> MishkaInstaller.PluginState.push_call()
    end)

    MishkaInstaller.Hook.unregister(module: List.first(@depends))
    assert length(MishkaInstaller.Plugin.plugins()) == 0
  end

  test "delete plugins dependencies with nested dependencies which exist, strategy one", %{this_is: _this_is} do
    clean_db()
    Enum.map(@plugins, fn x -> Map.from_struct(x) |> MishkaInstaller.Plugin.create() end)
    Enum.map(@plugins, fn item -> MishkaInstaller.PluginState.push_call(item) end)
    MishkaInstaller.Hook.unregister(module: "nested_plugin_one")
    assert length(MishkaInstaller.Plugin.plugins()) == 2
  end

  def clean_db() do
    MishkaInstaller.Plugin.plugins()
    |> Enum.map(fn x ->
      {:ok, :get_record_by_field, :plugin, repo_data} = MishkaInstaller.Plugin.show_by_name("#{x.name}")
      MishkaInstaller.Plugin.delete(repo_data.id)
    end)
  end
end
