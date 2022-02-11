defmodule MishkaInstaller do
  alias MishkaInstaller.PluginState

  @spec plugin_activity(String.t(), PluginState.t(), String.t(), String.t()) ::
          :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def plugin_activity(action, %PluginState{} = plugin, priority, status \\ "info") do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "plugin",
      section: "other",
      section_id: nil,
      action: action,
      priority: priority,
      status: status,
      user_id: nil
    }, Map.from_struct(plugin))
  end
end
