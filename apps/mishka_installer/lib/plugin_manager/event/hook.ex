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
      with {:ok, :ensure_event, _msg} <- ensure_event(event, :debug),
           {:error, :get_record_by_field, :plugin} <- Plugin.show_by_name("#{event.name}"),
           {:ok, :add, :plugin, _record_info} <- Plugin.create(Map.from_struct(event)) do
            PluginState.push_call(event)
            {:ok, :register, :activated}
      else
        {:error, :ensure_event, %{errors: check_data}} ->
          MishkaInstaller.plugin_activity("add", Map.merge(event, %{extra: extra}) , "high", "error")
          {:error, :register, check_data}
        {:ok, :get_record_by_field, :plugin, _record_info} ->
          PluginState.push_call(event)
          {:ok, :register, :activated}
        {:error, :add, :plugin, repo_error} ->
          MishkaInstaller.plugin_activity("add", Map.merge(event, %{extra: extra}) , "high", "error")
          {:error, :register, repo_error}
      end
    register_status
  end

  def register(event: %PluginState{} = event, depends: :force) do
    PluginState.push_call(event)
    {:ok, :register, :force}
  end

  def start(module: module_name) do
    with {:ok, :get_record_by_field, :plugin, record_info} <- Plugin.show_by_name("#{module_name}"),
         {:ok, :ensure_event, _msg} <- ensure_event(plugin_state_struct(record_info), :debug) do
          PluginState.push_call(plugin_state_struct(record_info) |> Map.merge(%{status: :started}))
          {:ok, :start, "The module's status was changed"}
    else
      {:error, :get_record_by_field, :plugin} -> {:error, :start, "The module concerned doesn't exist in the database."}
      {:error, :ensure_event, %{errors: check_data}} -> {:error, :start, check_data}
    end
  end

  def start(module: module_name, depends: :force) do
    with {:ok, :get_record_by_field, :plugin, record_info} <- Plugin.show_by_name("#{module_name}") do
      PluginState.push_call(plugin_state_struct(record_info) |> Map.merge(%{status: :started}))
      {:ok, :start, :force}
    else
      {:error, :get_record_by_field, :plugin} -> {:error, :start, "The module concerned doesn't exist in the database."}
    end
  end

  def start(event: event) do
    Plugin.plugins(event: event)
    |> Enum.map(&start(module: &1.name))
  end

  def start(event: event, depends: :force) do
    Plugin.plugins(event: event)
    |> Enum.map(&start(module: &1.name, depends: :force))
  end

  def restart(module: module_name) do
    with {:ok, :delete} <- PluginState.delete(module: module_name),
         {:ok, :get_record_by_field, :plugin, record_info} <- Plugin.show_by_name("#{module_name}"),
         {:ok, :ensure_event, _msg} <- ensure_event(plugin_state_struct(record_info), :debug) do
          PluginState.push_call(plugin_state_struct(record_info))
          {:ok, :restart, "The module concerned was restarted"}
    else
      {:error, :delete, :not_found} -> {:error, :restart, "The module concerned doesn't exist in the state."}
      {:error, :ensure_event, %{errors: check_data}} -> {:error, :restart, check_data}
      {:error, :get_record_by_field, :plugin} -> {:error, :restart, "The module concerned doesn't exist in the database."}
    end
  end

  def restart(module: module_name, depends: :force) do
    with {:ok, :delete} <- PluginState.delete(module: module_name),
         {:ok, :get_record_by_field, :plugin, record_info} <- Plugin.show_by_name("#{module_name}") do
          PluginState.push_call(plugin_state_struct(record_info))
          {:ok, :restart, "The module concerned was restarted"}
    else
      {:error, :delete, :not_found} -> {:error, :restart, "The module concerned doesn't exist in the state."}
      {:error, :get_record_by_field, :plugin} -> {:error, :restart, "The module concerned doesn't exist in the database."}
    end
  end

  def restart(event: event_name) do
    Plugin.plugins(event: event_name)
    |> Enum.map(&restart(module: &1.name))
  end

  def restart(event: event_name, depends: :force) do
    Plugin.plugins(event: event_name)
    |> Enum.map(&restart(module: &1.name, depends: :force))
  end

  def restart(depends: :force) do
    Plugin.plugins()
    |> Enum.map(&restart(module: &1.name, depends: :force))
  end

  def restart() do
    Plugin.plugins()
    |> Enum.map(&restart(module: &1.name))
  end

  def stop(module: module_name) do
    case PluginState.stop(module: module_name) do
      {:ok, :stop} -> {:ok, :stop, "The module concerned was stopped"}
      {:error, :stop, :not_found} -> {:error, :stop, "The module concerned doesn't exist in database."}
    end
  end

  def stop(event: event_name) do
    PSupervisor.running_imports(event_name)
    |> Enum.map(&stop(module: &1.id))
  end

  def delete(module: module_name) do
    case PluginState.delete(module: module_name) do
      {:ok, :delete} -> {:ok, :delete, "The module's state (#{module_name}) was deleted"}
      {:error, :delete, :not_found} -> {:error, :delete, "The module concerned (#{module_name}) doesn't exist in the state."}
    end
  end

  def delete(event: event_name) do
    PSupervisor.running_imports(event_name)
    |> Enum.map(&delete(module: &1.id))
  end

  def unregister(module: module_name) do
    with {:ok, :delete, _msg} <- delete(module: module_name),
         {:ok, :get_record_by_field, :plugin, record_info} <- Plugin.show_by_name(module_name),
         {:ok, :delete, :plugin, _} <- Plugin.delete(record_info.id) do

          Plugin.delete_plugins(module_name)
         {:ok, :unregister, "The module concerned (#{module_name}) and its dependencies were unregister"}
    else
      {:error, :delete, msg} -> {:error, :unregister, msg}
      {:error, :get_record_by_field, :plugin} -> {:error, :unregister, "The #{module_name} module doesn't exist in the database."}
      {:error, :delete, status, _error_tag} when status in [:uuid, :get_record_by_id, :forced_to_delete] ->
        {:error, :unregister, "There is a problem to find or delete the record in the database #{status}, module: #{module_name}"}
      {:error, :delete, :plugin, repo_error} -> {:error, :unregister, repo_error}
    end
  end

  def unregister(event: event_name) do
    Plugin.plugins(event: event_name)
    |> Enum.map(&unregister(module: &1.name))
  end

  def call(event: _event) do
    {:ok, :call}
  end

  # TODO: validate each module output and allowed_input
  def check_priority_of_events_registerd() do
    {:ok, :check_priority_of_events_registerd}
  end

  @spec ensure_event?(PluginState.t()) :: boolean
  def ensure_event?(%PluginState{depend_type: :hard, depends: depends} = event) do
    check_data = check_dependencies(depends, event.name)
    Enum.any?(check_data, fn {status, _error_atom, _event, _msg} -> status == :error end)
    |> case do
      true ->  false
      false -> true
    end
  end

  def ensure_event?(%PluginState{} = _event), do: true

  @spec ensure_event(PluginState.t(), :debug) ::
          {:error, :ensure_event, %{errors: list}} | {:ok, :ensure_event, String.t()}
  def ensure_event(%PluginState{depend_type: :hard, depends: depends} = event, :debug) when depends != [] do
    check_data = check_dependencies(depends, event.name)
    Enum.any?(check_data, fn {status, _error_atom, _event, _msg} -> status == :error end)
    |> case do
      true ->  {:error, :ensure_event, %{errors: check_data}}
      false -> {:ok, :ensure_event, "The modules concerned are activated"}
    end
  end

  def ensure_event(%PluginState{depend_type: :hard} = _event, :debug), do: {:ok, :ensure_event, "The modules concerned are activated"}
  def ensure_event(%PluginState{} = _event, :debug), do: {:ok, :ensure_event, "The modules concerned are activated"}

  defp check_dependencies(depends, event_name) do
    Enum.map(depends, fn evn ->
      with {:ensure_loaded, true} <- {:ensure_loaded, Code.ensure_loaded?(String.to_atom("Elixir.#{evn}"))},
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
    ++ [string_ensure_loaded(event_name)]
  end

  defp string_ensure_loaded(event_name) do
    case Code.ensure_loaded?(String.to_atom("Elixir.#{event_name}")) do
      true -> {:ok, :ensure_event, event_name, "The module concerned is activated"}
      false -> {:error, :ensure_loaded, event_name, "The module concerned doesn't exist."}
    end
  end

  defp plugin_state_struct(output) do
    %PluginState{
      name: output.name,
      event: output.event,
      priority: output.priority,
      status: output.status,
      depend_type: output.depend_type,
      depends: Map.get(output, :depends) || [],
      extra: Map.get(output, :extra) || []
    }
  end
end
