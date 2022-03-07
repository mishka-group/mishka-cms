defmodule MishkaContent.CorePlugin.Login.SuccessLogin do
  alias MishkaInstaller.Reference.OnUserAfterLogin
  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: OnUserAfterLogin,
      event: :on_user_after_login,
      initial: []

    @spec initial(list()) :: {:ok, OnUserAfterLogin.ref(), list()}
    def initial(args) do
      event = %PluginState{name: "MishkaContent.CorePlugin.Login.SuccessLogin", event: Atom.to_string(@ref), priority: 2}
      Hook.register(event: event)
      {:ok, @ref, args}
    end

    @spec call(OnUserAfterLogin.t()) :: {:reply, OnUserAfterLogin.t()}
    def call(%OnUserAfterLogin{} = state) do
      create_user_activity(state.user_info, state.ip, state.endpoint)
      start_user_bookmarks(state.user_info.id)
      {:reply, state}
    end

    defp create_user_activity(user_info, user_ip, endpoint) do
      MishkaContent.General.Activity.create_activity_by_task(%{
        type: if(endpoint == :html, do: "section", else: "internal_api"),
        section: "user",
        section_id: user_info.id,
        action: "auth",
        priority: "high",
        status: "info",
        user_id: user_info.id
      }, %{user_action: "login", user_ip: user_ip})
    end

    def start_user_bookmarks(user_id) do
      Task.Supervisor.async_nolink(MishkaHtmlWeb.AuthController.DeleteCurrentTokenTaskSupervisor, fn ->
        MishkaContent.Cache.BookmarkDynamicSupervisor.start_job([id: user_id, type: "user_bookmarks"])
      end)
    end
end
