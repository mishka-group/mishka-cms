defmodule MishkaUser.Acl.Access do
  @separator ":"

  def permittes?(action, user_id) do
    # need to be loaded on OTP state instead of db every page
    Enum.any?(MishkaUser.Acl.AclManagement.get_all(user_id).user_permission, fn %{value: permission} ->
      is_permitted?(action: action, permission: permission)
    end)
  end

  def is_permitted?(action: action, permission: permission) do
    permission_chunks = String.split(permission, @separator)
    String.split(action, @separator, parts: length(permission_chunks))
    |> check_permission(permission_chunks)
  end

  defp check_permission(action_chunks, permission_chunks)
    when length(permission_chunks) != length(action_chunks), do: false

  defp check_permission(action_chunks, permission_chunks) do
    Enum.zip(permission_chunks, action_chunks)
    |> Enum.find(fn {left, right} ->
      cond do
        left == "*" -> false
        left != right -> true
        true -> false
      end
    end)
    |> case do
      nil -> true
      _ -> false
    end
  end
end
