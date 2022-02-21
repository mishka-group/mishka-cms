defmodule MishkaInstallerTest.State.PluginDatabaseTest do
  use ExUnit.Case, async: false
  doctest MishkaInstaller
  setup_all _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
    # Ecto.Adapters.SQL.Sandbox.mode(MishkaDatabase.Repo, :auto)
    on_exit fn ->
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
      # Ecto.Adapters.SQL.Sandbox.mode(MishkaDatabase.Repo, :auto)
      clean_db()
      :ok
    end
    [this_is: "is"]
  end

  @depends ["joomla_login_plugin", "wordpress_login_plugin", "magento_login_plugin"]
  @new_soft_plugin %MishkaInstaller.PluginState{name: "plugin_one", event: "event_one"}

  @plugins [
    %MishkaInstaller.PluginState{name: "nested_plugin_one", event: "nested_event_one"},
    %MishkaInstaller.PluginState{name: "nested_plugin_two", event: "nested_event_one", depend_type: :hard, depends: ["unnested_plugin_three"]},
    %MishkaInstaller.PluginState{name: "unnested_plugin_three", event: "nested_event_one", depend_type: :hard, depends: ["nested_plugin_one"]},
    %MishkaInstaller.PluginState{name: "unnested_plugin_four", event: "nested_event_one"},
    %MishkaInstaller.PluginState{name: "unnested_plugin_five", event: "nested_event_one", depend_type: :hard, depends: ["unnested_plugin_four"]
    }
  ]

  @plugins2 [
    %MishkaInstaller.PluginState{name: "one", event: "one", depend_type: :soft},
    %MishkaInstaller.PluginState{name: "two", event: "one", depend_type: :hard, depends: ["one"]},
    %MishkaInstaller.PluginState{name: "three", event: "one", depend_type: :hard,depends: ["two"]},
    %MishkaInstaller.PluginState{name: "four", event: "one", depend_type: :hard, depends: ["three"]},
    %MishkaInstaller.PluginState{name: "five", event: "one", depend_type: :hard, depends: ["four"]}
  ]

  @plugins3 [
    %MishkaInstaller.PluginState{name: "one", event: "one", depend_type: :hard, depends: ["two"]},
    %MishkaInstaller.PluginState{name: "two", event: "one", depend_type: :hard, depends: ["four"]},
    %MishkaInstaller.PluginState{name: "three", event: "one", depend_type: :hard,depends: ["five"]},
    %MishkaInstaller.PluginState{name: "four", event: "one", depend_type: :hard, depends: ["three"]},
    %MishkaInstaller.PluginState{name: "five", event: "one", depend_type: :hard, depends: ["one"]}
  ]

  test "delete plugins dependencies with dependencies which do not exist", %{this_is: _this_is} do
    clean_db()
    Map.merge(@new_soft_plugin, %{depend_type: :hard, depends: @depends})
    |> Map.from_struct()
    |> MishkaInstaller.Plugin.create()

    MishkaInstaller.Plugin.delete_plugins("plugin_one")
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

    MishkaInstaller.Plugin.delete_plugins(List.first(@depends))
    assert length(MishkaInstaller.Plugin.plugins()) == 0

  end

  test "delete plugins dependencies with nested dependencies which exist, strategy one", %{this_is: _this_is} do
    clean_db()
    Enum.map(@plugins, fn x -> Map.from_struct(x) |> MishkaInstaller.Plugin.create() end)
    Enum.map(@plugins, fn item -> MishkaInstaller.PluginState.push_call(item) end)
    MishkaInstaller.Plugin.delete_plugins("nested_plugin_one")
    assert length(MishkaInstaller.Plugin.plugins()) == 3
  end

  test "delete plugins dependencies with nested dependencies which exist, strategy two", %{this_is: _this_is} do
    clean_db()
    Enum.map(@plugins2, fn x -> Map.from_struct(x) |> MishkaInstaller.Plugin.create() end)
    Enum.map(@plugins2, fn item -> MishkaInstaller.PluginState.push_call(item) end)
    MishkaInstaller.Plugin.delete_plugins("one")
    assert length(MishkaInstaller.Plugin.plugins()) == 1
  end

  test "delete plugins dependencies with nested dependencies which exist, strategy three", %{this_is: _this_is} do
    clean_db()
    Enum.map(@plugins3, fn x -> Map.from_struct(x) |> MishkaInstaller.Plugin.create() end)
    Enum.map(@plugins3, fn item -> MishkaInstaller.PluginState.push_call(item) end)
    MishkaInstaller.Plugin.delete_plugins("five")
    assert length(MishkaInstaller.Plugin.plugins()) == 0
  end

  def clean_db() do
    MishkaInstaller.Plugin.plugins()
    |> Enum.map(fn x ->
      {:ok, :get_record_by_field, :plugin, repo_data} = MishkaInstaller.Plugin.show_by_name("#{x.name}")
      MishkaInstaller.Plugin.delete(repo_data.id)
    end)
  end
end
