defmodule MishkaUser.Token.JWTToken do
  alias MishkaUser.Guardian
  alias MishkaUser.Token.TokenManagemnt

  @refresh_token_time 2000 #should be changed
  @access_token_time 2000 #should be changed

  def create_token(id, params \\ %{}, time, type) when type in ["access", "refresh", "current"] do
    {:ok, token, clime} = encode_and_sign_token(id, params, time, type)
    {:ok, String.to_atom(type), token, clime}
  end

  def encode_and_sign_token(id, params, time, type) do
    Guardian.encode_and_sign(%{id: "#{id}"}, Map.merge(%{some: "claim"}, params), token_type: type, ttl: {time, :seconds})
  end

  def refresh_token(token, time) do
    case Guardian.refresh(token, ttl: {time, :seconds}) do
      {:ok, _old_clime, {new_token, new_clime}} ->
        {:ok, :refresh_token, new_token, new_clime}

      result ->
        {:error, :refresh_token, result}
    end
  end

  def get_id_from_climes(climes) do
    Guardian.resource_from_claims(climes)
  end

  def verify_token(token) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} -> {:ok, :verify_token, claims}
      {:error, result} -> {:error, :verify_token, result}
    end
  end

  def create_refresh_acsses_token(user_info) do
    # Start Creating Token
    TokenManagemnt.start([], user_info.id)

    case TokenManagemnt.count_refresh_token(user_info.id) do
      {:ok, :count_refresh_token}->
        [
          %{user_id: user_info.id, time: token_time("refresh"), type: "refresh", token_id: Ecto.UUID.generate},
          %{user_id: user_info.id, time: token_time("access"), type: "access", token_id: Ecto.UUID.generate},
        ]
        |> Enum.map(fn x ->
          {:ok, action_atom, token, clime} =
            create_token(x.user_id, %{token_id: Ecto.UUID.generate}, x.time, x.type)
              save_token(
                %{
                  id: x.user_id,
                  token_id: x.token_id,
                  type: x.type,
                  token: token,
                  os: "linux",
                  create_time: clime["iat"],
                  last_used: clime["iat"],
                  exp: clime["exp"]}, x.user_id
                  # if type of token is access, it should be saved with refresh_token id
                )

            {:ok, action_atom, token, clime}
        end)
        |> get_refresh_and_access_token()

     _ ->
      {:error, :more_device}
    end
  end

  defp get_refresh_and_access_token([{:ok, :refresh, refresh_token, refresh_clime}, {:ok, :access, access_token, access_clime}]) do
    %{
      refresh_token: %{token: refresh_token, clime: refresh_clime},
      access_token:  %{token: access_token, clime: access_clime}
    }
  end


  def save_token(element, user_id) do
    TokenManagemnt.save(%{
      id: element.id,
      token_info:
        [
          %{
            token_id: element.token_id,
            type: element.type,
            token: element.token,
            os: element.os,
            create_time: element.create_time,
            last_used: element.create_time,
            access_expires_in: element.exp
            # if type of token is access, it should be saved with refresh_token id
          }
        ]
    }, user_id)
  end

  defp token_time("access"), do: @access_token_time
  defp token_time("refresh"), do: @refresh_token_time
end
