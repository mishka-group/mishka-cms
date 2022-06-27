defmodule MishkaUser.CorePlugin.Login.SuccessLogout do
  alias MishkaInstaller.Reference.OnUserAfterLogout

  use MishkaInstaller.Hook,
    module: __MODULE__,
    behaviour: OnUserAfterLogout,
    event: :on_user_after_logout,
    initial: []

  @spec initial(list()) :: {:ok, OnUserAfterLogout.ref(), list()}
  def initial(args) do
    event = %PluginState{
      name: "MishkaUser.CorePlugin.Login.SuccessLogout",
      event: Atom.to_string(@ref),
      priority: 1
    }

    Hook.register(event: event)
    {:ok, @ref, args}
  end

  @spec call(OnUserAfterLogout.t()) :: {:reply, OnUserAfterLogout.t()}
  def call(%OnUserAfterLogout{} = state) do
    MishkaUser.Acl.AclManagement.stop(state.user_id)
    {:reply, state}
  end
end
