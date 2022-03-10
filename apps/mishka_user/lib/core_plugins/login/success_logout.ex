defmodule MishkaUser.CorePlugin.Login.SuccessLogout do
  alias MishkaInstaller.Reference.OnUserAfterLogout
  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: OnUserAfterLogout,
      event: :on_user_after_logout,
      initial: []


    @spec initial(list()) :: {:ok, OnUserAfterLogout.ref(), list()}
    def initial(args) do
      event = %PluginState{name: "MishkaUser.CorePlugin.Login.SuccessLogout", event: Atom.to_string(@ref), priority: 1}
      Hook.register(event: event)
      {:ok, @ref, args}
    end

    @spec call(OnUserAfterLogout.t()) :: {:reply, OnUserAfterLogout.t()}
    def call(%OnUserAfterLogout{} = state) do
      create_user_permissions_on_state(state.user_id)
      {:reply, state}
    end

    defp create_user_permissions_on_state(user_id) do
      MishkaUser.Acl.AclManagement.save(%{
        id: user_id,
        user_permission: MishkaUser.User.permissions(user_id),
        created: System.system_time(:second)},
        user_id
      )
    end
end
