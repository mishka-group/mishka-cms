defmodule MishkaUser.Token.JWTToken do
  alias MishkaUser.Guardian
  alias MishkaUser.Token.TokenManagemnt

  @refresh_token_time 1124000
  @access_token_time 3600

  def create_token(id, params \\ %{}, time, type) when type in ["access", "refresh", "current"] do
    {:ok, token, clime} = encode_and_sign_token(id, params, time, type)
    {:ok, String.to_atom(type), token, clime}
  end

  def encode_and_sign_token(id, params, time, type) do
    Guardian.encode_and_sign(%{id: "#{id}"}, Map.merge(%{some: "claim"}, params), token_type: type, ttl: {time, :seconds})
  end

  def refresh_token(token) do
    case Guardian.refresh(token, ttl: {@refresh_token_time, :seconds}) do
      {:ok, {_old_token, %{"typ" => "refresh"}}, {new_token, new_clime}} ->

        {:ok, :verify_token, new_token, new_clime}
        |> verify_refresh_token_on_state(token)
        |> delete_old_token(token)
        |> create_new_refresh_token()

      result ->
        {:error, :verify_token, result}
        |> delete_old_token(token)
    end
  end


  defp verify_refresh_token_on_state({:ok, :verify_token, new_token, new_clime}, token) do
    {:ok, %{id: id}} = get_id_from_climes(new_clime)
    case TokenManagemnt.get_token(id, token) do
      nil -> {:error, :verify_token, :token_otp_state}
      _data -> {:ok, :verify_token, new_token, new_clime}
    end
  end


  defp delete_old_token({:ok, :verify_token, _new_token, new_clime}, token) do
    {:ok, %{id: id}} = get_id_from_climes(new_clime)
    TokenManagemnt.delete_child_token(id, token)
    TokenManagemnt.delete_token(id, token)

    {:ok, :delete_old_token, new_clime}
  end

  defp delete_old_token({:error, error_function, action}, _token), do: {:error, error_function, :refresh, action}

  defp create_new_refresh_token({:ok, :delete_old_token, clime}) do
    {:ok, %{id: id}} = get_id_from_climes(clime)
    create_refresh_acsses_token(%{id: id})
  end

  defp create_new_refresh_token({:error, error_function, :refresh, :token_otp_state}) do
    {:error, error_function, :refresh, :token_otp_state}
  end

  defp create_new_refresh_token({:error, error_function, :refresh, action}), do: {:error, error_function, :refresh, action}


  def get_id_from_climes(climes), do: Guardian.resource_from_claims(climes)

  def verify_token(token, type) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} -> {:ok, :verify_token, type, claims}
      {:error, action} -> {:error, :verify_token, type, action}
    end
    |> verify_token_on_state(token)
  end

  defp verify_token_on_state({:ok, :verify_token, type, claims}, token) do
    {:ok, %{id: id}} = get_id_from_climes(claims)
    case TokenManagemnt.get_token(id, token) do
      nil -> {:error, :verify_token, type, :token_otp_state}
      _clime -> {:ok, :verify_token, type, Map.merge(claims, %{"id" => id})}
    end
  end

  defp verify_token_on_state({:error, :verify_token, type, action}, _token), do: {:error, :verify_token, type, action}


  def create_refresh_acsses_token(user_info) do
    MishkaUser.Token.TokenDynamicSupervisor.start_job([id: user_info.id, type: "token"])

    case TokenManagemnt.count_refresh_token(user_info.id) do
      {:ok, :count_refresh_token}->
        refresh_token_id = Ecto.UUID.generate
        [
          %{user_id: user_info.id, time: token_time("refresh"), type: "refresh", token_id: refresh_token_id},
          %{user_id: user_info.id, time: token_time("access"), type: "access", token_id: Ecto.UUID.generate},
        ]
        |> Enum.map(fn x ->
          {:ok, action_atom, token, clime} =
            create_token(x.user_id, %{token_id: Ecto.UUID.generate}, x.time, x.type)
              rel = if x.type == "access", do: refresh_token_id, else: nil
              save_token(
                %{
                  id: x.user_id,
                  token_id: x.token_id,
                  type: x.type,
                  token: token,
                  os: "linux",
                  create_time: clime["iat"],
                  last_used: clime["iat"],
                  exp: clime["exp"],
                  rel: rel
                  }, x.user_id
                )

            {:ok, action_atom, token, Map.merge(clime, %{"id" => x.user_id})}
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
            access_expires_in: element.exp,
            rel: element.rel
          }
        ]
    }, user_id)
  end

  defp token_time("access"), do: @access_token_time
  defp token_time("refresh"), do: @refresh_token_time

  def delete_refresh_token(token) do
    case refresh_delete_token(token) do
      {:ok, :delete_old_token, _new_clime} -> {:ok, :delete_refresh_token}

      {:error, _error_function, :refresh, action} -> {:error, :delete_refresh_token, action}
    end
  end

  defp refresh_delete_token(token) do
    case Guardian.refresh(token, ttl: {@refresh_token_time, :seconds}) do
      {:ok, {_old_token, %{"typ" => "refresh"}}, {new_token, new_clime}} ->

        {:ok, :verify_token, new_token, new_clime}
        |> verify_refresh_token_on_state(token)
        |> delete_old_token(token)

      result ->
        {:error, :verify_token, result}
        |> delete_old_token(token)
    end
  end

end
