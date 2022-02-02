defmodule MishkaInstaller do
  # TODO: it needs delegate
  alias MishkaInstaller.PluginState

  @spec plugin_activity(String.t(), PluginState.t(), String.t(), String.t()) :: Task.t()
  def plugin_activity(action, %PluginState{} = plugin, priority, status \\ "info") do
    MishkaContent.General.Activity.create_activity_by_task(%{
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
