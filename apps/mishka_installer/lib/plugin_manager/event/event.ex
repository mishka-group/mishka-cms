defmodule MishkaInstaller.Event do

  alias __MODULE__
  alias MishkaInstaller.Reference, as: Ref
  @type event :: %Event{name: atom(), section: atom(), reference: module()}

  defstruct [:name, :section, :reference]
  # TODO: bind all plugins events


  @spec system_events :: [event]
  def system_events do
    [
      # Content
      %Event{name: :on_content_prepare, section: :mishka_content, reference: Ref.OnContentPrepare},
      %Event{name: :on_content_after_title, section: :mishka_content, reference: Ref.OnContentAfterTitle},
      %Event{name: :on_content_before_display, section: :mishka_content, reference: Ref.OnContentBeforeDisplay},
      %Event{name: :on_content_after_display, section: :mishka_content, reference: Ref.OnContentAfterDisplay},
      %Event{name: :on_content_before_save, section: :mishka_content, reference: Ref.OnContentBeforeSave},
      %Event{name: :on_content_after_save, section: :mishka_content, reference: Ref.OnContentAfterSave},
      %Event{name: :on_content_prepare_form, section: :mishka_content, reference: Ref.OnContentPrepareForm},
      %Event{name: :on_content_prepare_data, section: :mishka_content, reference: Ref.OnContentPrepareData},
      %Event{name: :on_content_before_delete, section: :mishka_content, reference: Ref.OnContentBeforeDelete},
      %Event{name: :on_content_after_delete, section: :mishka_content, reference: Ref.OnContentAfterDelete},
      %Event{name: :on_content_change_state, section: :mishka_content, reference: Ref.OnContentChangeState},
      %Event{name: :on_content_search, section: :mishka_content, reference: Ref.OnContentSearch},
      %Event{name: :on_content_search_areas, section: :mishka_content, reference: Ref.OnContentSearchAreas},
      %Event{name: :on_user_before_data_validation, section: :mishka_content, reference: Ref.OnUserBeforeDataValidation},
      # Captcha
      %Event{name: :on_init, section: :mishka_user, reference: Ref.OnInit},
      %Event{name: :on_display, section: :mishka_user, reference: Ref.OnDisplay},
      %Event{name: :on_check_answer, section: :mishka_user, reference: Ref.OnCheckAnswer},
      %Event{name: :on_privacy_collect_admin_capabilities, section: :mishka_user, reference: Ref.OnPrivacyCollectAdminCapabilities},
      # User
      %Event{name: :on_user_authorisation, section: :mishka_user, reference: Ref.OnUserAuthorisation},
      %Event{name: :on_user_authorisation_failure, section: :mishka_user, reference: Ref.OnUserAuthorisationFailure},
      %Event{name: :on_user_before_save, section: :mishka_user, reference: Ref.OnUserBeforeSave},
      %Event{name: :on_user_after_save, section: :mishka_user, reference: Ref.OnUserAfterSave},
      %Event{name: :on_user_before_delete, section: :mishka_user, reference: Ref.OnUserBeforeDelete},
      %Event{name: :on_user_after_delete, section: :mishka_user, reference: Ref.OnUserAfterDelete},
      %Event{name: :on_user_login, section: :mishka_user, reference: Ref.OnUserLogin},
      %Event{name: :on_user_login_failure, section: :mishka_user, reference: Ref.OnUserLoginFailure},
      %Event{name: :on_user_after_login, section: :mishka_user, reference: Ref.OnUserAfterLogin},
      %Event{name: :on_user_logout, section: :mishka_user, reference: Ref.OnUserLogout},
      %Event{name: :on_user_before_save_role, section: :mishka_user, reference: Ref.OnUserBeforeSaveRole},
      %Event{name: :on_user_after_save_role, section: :mishka_user, reference: Ref.OnUserAfterSaveRole},
      %Event{name: :on_user_before_delete_role, section: :mishka_user, reference: Ref.OnUserBeforeDeleteRole},
      %Event{name: :on_user_after_delete_role, section: :mishka_user, reference: Ref.OnUserAfterDeleteRole},
      %Event{name: :on_user_after_remind, section: :mishka_user, reference: Ref.OnUserAfterRemind},
    ]
  end
end
