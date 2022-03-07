defmodule MishkaContent.CorePlugin.Login.SuccessLogout do
  alias MishkaInstaller.Reference.OnUserAfterLogout
  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: OnUserAfterLogout,
      event: :on_user_after_logout,
      initial: []


    @spec initial(list()) :: {:ok, OnUserAfterLogout.ref(), list()}
    def initial(args) do
      event = %PluginState{name: "MishkaContent.CorePlugin.Login.SuccessLogout", event: Atom.to_string(@ref), priority: 2}
      Hook.register(event: event)
      {:ok, @ref, args}
    end

    @spec call(OnUserAfterLogout.t()) :: {:reply, OnUserAfterLogout.t()}
    def call(%OnUserAfterLogout{} = state) do
      create_user_activity(state.user_id, state.ip)
      {:reply, state}
    end

    defp create_user_activity(user_id, user_ip) do
      MishkaContent.General.Activity.create_activity_by_task(%{
        type: "section",
        section: "user",
        section_id: nil,
        action: "auth",
        priority: "high",
        status: "info",
        user_id: user_id
      }, %{user_action: "log_out", user_ip: user_ip})
    end
end
