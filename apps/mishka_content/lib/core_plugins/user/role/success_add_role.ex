defmodule MishkaContent.CorePlugin.UserRole.SuccessAddRole do
  alias MishkaInstaller.Reference.OnUserAfterSaveRole
  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: OnUserAfterSaveRole,
      event: :on_user_after_save_role,
      initial: []

    @spec initial(list()) :: {:ok, OnUserAfterSaveRole.ref(), list()}
    def initial(args) do
      event = %PluginState{name: "MishkaContent.CorePlugin.UserRole.SuccessAddRole", event: Atom.to_string(@ref), priority: 2}
      Hook.register(event: event)
      {:ok, @ref, args}
    end

    @spec call(OnUserAfterSaveRole.t()) :: {:reply, OnUserAfterSaveRole.t()}
    def call(%OnUserAfterSaveRole{} = state) do
      create_user_activity(state.role_id, state.ip, state.endpoint, state.conn)
      delete_user_bookmarks(state.conn)
      {:reply, state}
    end

    defp create_user_activity(role_id, user_ip, endpoint, socket) do
      MishkaContent.General.Activity.create_activity_by_start_child(%{
        type: if(endpoint == :html, do: "section", else: "internal_api"),
        section: "role",
        section_id: role_id,
        action: "add",
        priority: "high",
        status: "info",
        user_id: socket.assigns.user_id
      }, %{user_action: "live_role_create", user_ip: MishkaInstaller.ip(user_ip)})
    end

    def delete_user_bookmarks(socket) do
      if(!is_nil(Map.get(socket.assigns, :draft_id))) do
        MishkaContent.Cache.ContentDraftManagement.delete_record(id: socket.assigns.draft_id)
      end
    end
end
