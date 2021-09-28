defmodule MishkaContent do
  def db_content_activity_error(section, action, db_error) do
    MishkaContent.General.Activity.create_activity_by_task(%{
      type: "db",
      section: section,
      section_id: nil,
      action: action,
      priority: "high",
      status: "error",
      user_id: nil
    }, %{
        db_rescue_struct: db_error.__struct__,
        message: Map.get(db_error, :message),
        values: Map.get(db_error, :value),
        type: Map.get(db_error, :type),
      }
    )
  end
end
