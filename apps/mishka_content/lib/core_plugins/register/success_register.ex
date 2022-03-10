defmodule MishkaContent.CorePlugin.Register.SuccessRegister do
  alias MishkaInstaller.Reference.OnUserAfterSave
  alias MishkaDatabase.Cache.RandomCode
  # TODO: should be on config file or ram
  @hard_secret_random_link "Test refresh"

  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: OnUserAfterSave,
      event: :on_user_after_save,
      initial: []

    @spec initial(list()) :: {:ok, OnUserAfterSave.ref(), list()}
    def initial(args) do
      event = %PluginState{name: "MishkaContent.CorePlugin.Register.SuccessRegister", event: Atom.to_string(@ref), priority: 2}
      Hook.register(event: event)
      {:ok, @ref, args}
    end

    @spec call(OnUserAfterSave.t()) :: {:reply, OnUserAfterSave.t()}
    def call(%OnUserAfterSave{} = state) do
      create_user_activity(state.user_info, state.ip, state.endpoint, state.status)
      sending_random_code(state.endpoint, state.user_info, state.extra)
      {:reply, state}
    end

    defp create_user_activity(user_info, user_ip, endpoint, status) do
      MishkaContent.General.Activity.create_activity_by_start_child(%{
        type: if(endpoint == :html, do: "section", else: "internal_api"),
        section: "user",
        section_id: user_info.id,
        action: "add",
        priority: "medium",
        status: "info",
        user_id: user_info.id
      }, %{identity_provider: status, user_action: "register", user_ip: MishkaInstaller.ip(user_ip)})
    end

    defp sending_random_code(:api, user_info, _extra) do
      random_code = Enum.random(100000..999999)
      RandomCode.save(user_info.email, random_code)
      MishkaContent.Email.EmailHelper.send(:verify_email, {user_info.email, random_code})
    end

    defp sending_random_code(:html, user_info, extra) do
      random_link =
        Phoenix.Token.sign(MishkaHtmlWeb.Endpoint, @hard_secret_random_link, %{id: user_info.id, type: "access"}, [key_digest: :sha256])
        RandomCode.save(user_info.email, random_link)
        site_link = MishkaContent.Email.EmailHelper.email_site_link_creator(
          extra.site_url,
          String.replace(extra.endpoint_uri, "random_link", random_link)
        )
      MishkaContent.Email.EmailHelper.send(:verify_email, {user_info.email, site_link})
    end
end
