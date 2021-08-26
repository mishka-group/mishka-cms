defmodule MishkaUser.Guardian do
  use Guardian, otp_app: :mishka_user

  @spec subject_for_token(atom | %{id: any}, any) :: {:ok, binary}
  def subject_for_token(resource, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = to_string(resource.id)
    {:ok, sub}
  end

  @spec subject_for_token :: {:error, :reason_for_error}
  def subject_for_token() do
    {:error, :reason_for_error}
  end

  @spec resource_from_claims(nil | maybe_improper_list | map) :: {:ok, %{id: any}}
  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    id = claims["sub"]
    resource = get_resource_by_id(id)
    {:ok,  resource}
  end

  @spec resource_from_claims :: {:error, :reason_for_error}
  def resource_from_claims() do
    {:error, :reason_for_error}
  end


  @spec get_resource_by_id(binary()) :: %{id: any}
  def get_resource_by_id(id) do
    %{id: id}
  end
end
