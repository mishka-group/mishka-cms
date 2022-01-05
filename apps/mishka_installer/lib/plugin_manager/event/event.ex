defmodule MishkaInstaller.Event do
  alias __MODULE__
  alias MishkaInstaller.Reference, as: Ref
  defstruct [:name, :section, :reference, allowed_input: :tuple, allowed_output: :tuple]

  # TODO: we need optional @callback for each defualt system event, for init and call functions

  # TODO: bind all plugins events

  # TODO: Define developers custom plugins events

  @type event :: %{name: atom(), section: atom(), reference: module(), allowed_input: map(), allowed_output: map()}

  @spec system_events() :: list(event())
  def system_events do
    [
      # TODO: allowed_input and allowed_output should be a list of keywords which are allowed, but we need different output like state
      # Content
      %Event{name: :on_content_prepare, section: :mishka_content, reference: Ref.OnContentPrepare},
      %Event{name: :on_content_after_title, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_before_display, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_After_display, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_before_save, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_After_save, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_Prepare_form, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_Prepare_data, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_before_delete, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_After_delete, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_Change_state, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_search, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_content_search_areas, section: :mishka_content, reference: MishkaInstaller.Event},
      %Event{name: :on_user_before_data_validation, section: :mishka_content, reference: MishkaInstaller.Event},

      # Captcha
      %Event{name: :on_init, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_display, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_check_answer, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_privacy_collect_admin_capabilities, section: :mishka_user, reference: MishkaInstaller.Event},

      # User
      %Event{name: :on_user_authorisation, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_authorisationFailure, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_before_save, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_after_save, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_userBefore_delete, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_after_delete, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_userLogin, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_userLogin_failure, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_after_login, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_logout, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_before_save_role, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_after_save_role, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_before_delete_role, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_after_delete_role, section: :mishka_user, reference: MishkaInstaller.Event},
      %Event{name: :on_user_after_remind, section: :mishka_user, reference: MishkaInstaller.Event},
    ]
  end
end
