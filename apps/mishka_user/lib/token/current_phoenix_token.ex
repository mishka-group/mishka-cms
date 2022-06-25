defmodule MishkaUser.Token.CurrentPhoenixToken do
  alias MishkaUser.Token.TokenManagemnt

  @type data_uuid() :: Ecto.UUID.t
  @type token() :: String.t()

  @spec create_token(data_uuid() | String.t(), :current) :: {:ok, :current, nonempty_binary}
  def create_token(id, :current) do
    token = Phoenix.Token.sign(MishkaApiWeb.Endpoint, System.get_env("SECRET_CURRENT_TOKEN_SALT"), %{id: id, type: "access"}, [key_digest: :sha256])
    {:ok, :current, token}
  end



  @spec save_token(map()) :: {:ok, :save_token, nonempty_binary}
  def save_token(user_info) do
    {:ok, type, token} = create_token(user_info.id, :current)
    TokenManagemnt.save(%{
      id: user_info.id,
      token_info:
        %{
          token_id: Ecto.UUID.generate,
          type: Atom.to_string(type),
          token: token,
          os: "linux",
          create_time: System.system_time(:second),
          last_used: System.system_time(:second),
          access_expires_in: token_expire_time(:current).unix_time,
          rel: nil
        }
    }, user_info.id)

    {:ok, :save_token, token}
  end

  @spec verify_token(nil | token(), atom()) :: tuple()
  def verify_token(token, :current) do
    Phoenix.Token.verify(MishkaApiWeb.Endpoint, System.get_env("SECRET_CURRENT_TOKEN_SALT"), token, [max_age: token_expire_time(:current).age])
    |> verify_token_condition(:current)
    |> verify_token_on_state(token)
  end

  defp verify_token_condition(state, type) do
    state
    |> case do
      {:ok, clime} -> {:ok, :verify_token, type, clime}
      {:error, action} -> {:error, :verify_token, type, action}
    end
  end

  defp verify_token_on_state({:ok, :verify_token, type, clime}, token) do
    case TokenManagemnt.get_token(clime.id, token) do
      nil -> {:error, :verify_token, type, :token_otp_state}
      state ->
        {:ok, :verify_token, type,
        Map.new(state, fn {k, v} -> {Atom.to_string(k), v} end)
        |> Map.merge(%{"id" => clime.id})
      }
    end
  end

  defp verify_token_on_state({:error, :verify_token, type, action}, _token), do: {:error, :verify_token, type, action}

  defp token_expire_time(:current) do
    %{
      unix_time: DateTime.utc_now() |> DateTime.add(10800, :second) |> DateTime.to_unix(),
      age: 10800
    }
  end
end
