defmodule MishkaInstallerTest.Event.HookTest do
  use ExUnit.Case, async: false
  doctest MishkaInstaller
  alias MishkaInstaller.Hook

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
  @new_soft_plugin %MishkaInstaller.PluginState{name: "plugin_hook_one", event: "event_one"}

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

  test "register plugin, soft depend_type", %{this_is: _this_is} do
    clean_db()
    assert Hook.register(event: @new_soft_plugin) == {:ok, :register, :activated}
    assert Hook.register(event: @new_soft_plugin) == {:ok, :register, :activated}
  end

  test "register plugin, hard depend_type", %{this_is: _this_is} do
    clean_db()
    # It is just not enough to set hard as depend_type, you should have some deps in depends list more than 0
    # I think the developer maybe create a mistake, so it let him start his app instead of stopping when we have no depends
    {:error, :register, _check_data} = assert Hook.register(event: Map.merge(@new_soft_plugin, %{depend_type: :hard, depends: ["test1", "test2"]}))
    {:error, :register, _check_data} = assert Hook.register(event: Map.merge(@new_soft_plugin, %{name: ""}))
  end


  test "start a registerd plugin", %{this_is: _this_is} do
    clean_db()
    Hook.register(event: @new_soft_plugin)
    {:ok, :start, "The module's status was changed"} = assert Hook.start(module: @new_soft_plugin.name)
    Hook.register(event: Map.merge(@new_soft_plugin, %{name: "ensure_event_plugin", depend_type: :hard, depends: ["test1", "test2"]}))
    {:error, :start, _msg} = assert Hook.start(module: "ensure_event_plugin")
  end

  test "restart a registerd plugin", %{this_is: _this_is} do
    clean_db()
    Hook.register(event: @new_soft_plugin)
    {:ok, :start, "The module's status was changed"} = assert Hook.start(module: @new_soft_plugin.name)
    {:ok, :restart, _msg} = assert Hook.restart(module: @new_soft_plugin.name)
    Map.merge(@new_soft_plugin, %{name: "ensure_event_plugin", depend_type: :hard, depends: ["test1", "test2"]})
    |> Map.from_struct()
    |> MishkaInstaller.Plugin.create()
    {:error, :restart, _msg} = assert Hook.restart(module: "ensure_event_plugin")
    {:error, :restart, _msg} = assert Hook.restart(module: "none_plugin")
  end

  test "restart a registerd plugin force type", %{this_is: _this_is} do
    clean_db()
    Hook.register(event: @new_soft_plugin)
    {:ok, :start, "The module's status was changed"} = assert Hook.start(module: @new_soft_plugin.name)
    Map.merge(@new_soft_plugin, %{name: "ensure_event_plugin", depend_type: :hard, depends: ["test1", "test2"]})
    |> Map.from_struct()
    |> MishkaInstaller.Plugin.create()
    {:ok, :restart, _msg} = assert Hook.restart(module: @new_soft_plugin.name, depends: :force)
    {:error, :restart, _msg} = assert Hook.restart(module: "none_plugin", depends: :force)
  end

  test "stop a registerd plugin", %{this_is: _this_is} do
    clean_db()
    Hook.register(event: @new_soft_plugin)
    {:ok, :stop, _msg} = assert Hook.stop(module: @new_soft_plugin.name)
    {:error, :stop, _msg} = assert Hook.stop(module: "none_plugin")
  end

  test "delete a registerd plugin", %{this_is: _this_is} do
    clean_db()
    Hook.register(event: @new_soft_plugin)
    {:ok, :delete, _msg} = assert Hook.delete(module: @new_soft_plugin.name)
    {:error, :delete, _msg} = assert Hook.delete(module: "none_plugin")
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

    # it tests MishkaInstaller.Plugin.delete_plugins
    Hook.unregister(module: List.first(@depends))
    assert length(MishkaInstaller.Plugin.plugins()) == 0

  end

  test "delete plugins dependencies with nested dependencies which exist, strategy one", %{this_is: _this_is} do
    clean_db()
    Enum.map(@plugins, fn x -> Map.from_struct(x) |> MishkaInstaller.Plugin.create() end)
    Enum.map(@plugins, fn item -> MishkaInstaller.PluginState.push_call(item) end)
    # it tests MishkaInstaller.Plugin.delete_plugins
    Hook.unregister(module: "nested_plugin_one")
    assert length(MishkaInstaller.Plugin.plugins()) == 2
  end

  test "delete plugins dependencies with nested dependencies which exist, strategy two", %{this_is: _this_is} do
    clean_db()
    Enum.map(@plugins2, fn x -> Map.from_struct(x) |> MishkaInstaller.Plugin.create() end)
    Enum.map(@plugins2, fn item -> MishkaInstaller.PluginState.push_call(item) end)
    # it tests MishkaInstaller.Plugin.delete_plugins
    Hook.unregister(module: "one")
    assert length(MishkaInstaller.Plugin.plugins()) == 0
  end

  test "delete plugins dependencies with nested dependencies which exist, strategy three", %{this_is: _this_is} do
    clean_db()
    Enum.map(@plugins3, fn x -> Map.from_struct(x) |> MishkaInstaller.Plugin.create() end)
    Enum.map(@plugins3, fn item -> MishkaInstaller.PluginState.push_call(item) end)
    # it tests MishkaInstaller.Plugin.delete_plugins
    Hook.unregister(module: "five")
    assert length(MishkaInstaller.Plugin.plugins()) == 0
  end

  test "ensure_event?" do
    Hook.register(event: @new_soft_plugin |> Map.merge(%{name: "MishkaInstaller.PluginState"}))
    test_plug =
      %MishkaInstaller.PluginState{name: "MishkaInstaller.Hook", event: "event_one", depend_type: :hard, depends: ["MishkaInstaller.PluginState"]}

    {:ok, :ensure_event, _msg} = assert Hook.ensure_event(test_plug, :debug)
    true = assert Hook.ensure_event?(test_plug)
  end

  def clean_db() do
    MishkaInstaller.Plugin.plugins()
    |> Enum.map(fn x ->
      {:ok, :get_record_by_field, :plugin, repo_data} = MishkaInstaller.Plugin.show_by_name("#{x.name}")
      MishkaInstaller.Plugin.delete(repo_data.id)
    end)
  end
end
