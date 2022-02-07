defmodule MishkaInstaller.Hook do
  alias MishkaInstaller.PluginState
  #### Starting Priority Check ####
  # if a package has a hight priority like 100 and there are 3 more package
  # if there is no `depends` for this packages, Then start with the lowest priority, and pass theire `{:reply, new_state}` to higher
  # than before.
  # but if `depends` for each of thease packages exists, then check if the specific package is loaded or not! if not `{:noreply, :halt}`
  # if yes use `{:reply, new_state}`
  # it should be noted, any package that wants to be stopped in this way just loads `{:noreply, :halt}`, after doing this, the higher
  # priority plugins are not loaded or run
  # Hook just needs to load :started status
  #### Finishing Priority Check ####

  def register(event: %PluginState{} = event) do
    if ensure_event(event) do
      PluginState.push(event)
      {:ok, :register, :activated}
    else
      extra = (event.extra || []) ++ [%{operations: :hook}, %{fun: :register}]
      MishkaInstaller.plugin_activity("add", Map.merge(event, %{extra: extra}) , "high", "error")
      {:error, :register, :inactive_dependencies}
    end
  end

  def register(event: %PluginState{} = _event, depends: :force) do
    # TODO: enable all the deps events
  end

  # TODO: start a module
  def start(module: _module_name) do
    {:ok, :stop}
  end

  def start(event: _event) do
    {:ok, :stop}
  end

  # TODO: restart a module
  def restart(module: _module_name) do
    {:ok, :reset}
  end

  def restart(event: _event) do
    {:ok, :reset}
  end

  # TODO: stop a module
  def stop(module: _module_name) do
    # TODO: check the type of depend_type and disable all the dependes events if it is hard type
    {:ok, :stop}
  end

  def stop(event: _event) do
    # TODO: check the type of depend_type and disable all the dependes events if it is hard type
    {:ok, :stop}
  end

  def call(event: _event) do
    {:ok, :call}
  end

  def delete(event: _event) do
    # TODO: check the type of depend_type and disable all the dependes events if it is hard type
    # TODO: it should delete simple store fields like xml joomla config
    {:ok, :delete}
  end

  def delete(module: _module_name) do
    # TODO: check the type of depend_type and disable all the dependes events if it is hard type
    # TODO: it should delete simple store fields like xml joomla config
    {:ok, :delete}
  end

  # TODO: validate each module output and allowed_input
  def check_priority_of_events_registerd() do
    {:ok, :check_priority_of_events_registerd}
  end

  def ensure_event(%PluginState{depend_type: :hard, depends: depends} = _event) do
    Enum.filter(depends, fn evn ->
      !Code.ensure_loaded?(evn.evn) && Map.get(PluginState.get(module: evn.evn), :status) != :started
    end)
    |> length() == 0
  end

  def ensure_event(%PluginState{} = _event), do: true
end
