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

  def get_size_of_words(string, count) when not is_nil(string) do
    string
    |> String.split(" ")
    |> Enum.with_index(fn element, index -> if index <= count, do: element end)
    |> Enum.reject(fn item -> is_nil(item) end)
    |> Enum.join(" ")
  end
end
