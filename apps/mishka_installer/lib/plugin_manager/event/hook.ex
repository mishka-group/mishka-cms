defmodule MishkaInstaller.Hook do
  alias MishkaInstaller.PluginState
  alias MishkaInstaller.PluginStateDynamicSupervisor, as: PSupervisor
  alias MishkaInstaller.Plugin
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
    extra = (event.extra || []) ++ [%{operations: :hook}, %{fun: :register}]
    register_status =
      with {:ok, :ensure_event, "The modules concerned are activated"} <- ensure_event(event, :debug),
           {:error, :get_record_by_field, :plugin} <- Plugin.show_by_name("#{event.name}"),
           {:ok, :add, :plugin, record_info} <- Plugin.create(Map.from_struct(event)) do
            PSupervisor.start_job(%{id: record_info.name, type: record_info.event})
            {:ok, :register, :activated}
      else
        {:error, :ensure_event, %{errors: check_data}} ->
          MishkaInstaller.plugin_activity("add", Map.merge(event, %{extra: extra}) , "high", "error")
          {:error, :register, check_data}
        {:ok, :get_record_by_field, :plugin, _record_info} ->
          PluginState.push(event)
          {:ok, :register, :activated}
        {:error, :add, :plugin, repo_error} ->
          MishkaInstaller.plugin_activity("add", Map.merge(event, %{extra: extra}) , "high", "error")
          {:error, :register, repo_error}
      end
    register_status
  end

  def register(event: %PluginState{} = event, depends: :force) do
    PluginState.push(event)
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

  def ensure_event?(%PluginState{depend_type: :hard, depends: depends} = _event) do
    check_data = check_dependencies(depends)
    Enum.any?(check_data, fn {status, _error_atom, _event, _msg} -> status == :error end)
    |> case do
      true ->  false
      false -> true
    end
  end

  def ensure_event?(%PluginState{} = _event), do: true

  def ensure_event(%PluginState{depend_type: :hard, depends: depends} = _event, :debug) when depends != [] do
    check_data = check_dependencies(depends)
    Enum.any?(check_data, fn {status, _error_atom, _event, _msg} -> status == :error end)
    |> case do
      true ->  {:error, :ensure_event, %{errors: check_data}}
      false -> {:ok, :ensure_event, "The modules concerned are activated"}
    end
  end

  def ensure_event(%PluginState{depend_type: :hard} = _event, :debug), do: {:ok, :ensure_event, "The modules concerned are activated"}

  defp check_dependencies(depends) do
    Enum.map(depends, fn evn ->
      with {:ensure_loaded, true} <- {:ensure_loaded, Code.ensure_loaded?(String.to_atom(evn))},
           plugin_state <- PluginState.get(module: evn),
           {:plugin_state?, true, _state} <- {:plugin_state?, is_struct(plugin_state), plugin_state},
           {:activated_plugin, true, _state} <- {:activated_plugin, Map.get(plugin_state, :status) == :started, plugin_state} do

          {:ok, :ensure_event, evn, "The module concerned is activated"}
      else
        {:ensure_loaded, false} -> {:error, :ensure_loaded, evn, "The module concerned doesn't exist."}
        {:plugin_state?, false, _state} -> {:error, :plugin_state?, evn, "The event concerned doesn't exist in state."}
        {:activated_plugin, false, _state} -> {:error, :activated_plugin, evn, "The event concerned is not activated."}
      end
    end)
  end
end
