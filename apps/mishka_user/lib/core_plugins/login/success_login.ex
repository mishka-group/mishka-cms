defmodule MishkaUser.CorePlugin.Login.SuccessLogin do
  alias MishkaInstaller.Reference.OnUserAfterLogin

  use MishkaInstaller.Hook,
    module: __MODULE__,
    behaviour: OnUserAfterLogin,
    event: :on_user_after_login,
    initial: []

  @spec initial(list()) :: {:ok, OnUserAfterLogin.ref(), list()}
  def initial(args) do
    event = %PluginState{
      name: "MishkaUser.CorePlugin.Login.SuccessLogin",
      event: Atom.to_string(@ref),
      priority: 1
    }

    Hook.register(event: event)
    {:ok, @ref, args}
  end

  @spec call(OnUserAfterLogin.t()) :: {:reply, OnUserAfterLogin.t()}
  def call(%OnUserAfterLogin{} = state) do
    create_user_permissions_on_state(state.user_info)
    {:reply, state}
  end

  defp create_user_permissions_on_state(user_info) do
    MishkaUser.Acl.AclManagement.save(
      %{
        id: user_info.id,
        user_permission: MishkaUser.User.permissions(user_info.id),
        created: System.system_time(:second)
      },
      user_info.id
    )
  end
end
