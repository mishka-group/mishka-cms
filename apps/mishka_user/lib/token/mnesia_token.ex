defmodule MishkaUser.Token.MnesiaToken do
  alias :mnesia, as: Mnesia

  def start_mnesia_token() do
    Mnesia.create_schema([node()])
    Mnesia.start()

    case Mnesia.create_table(Token, [disc_only_copies: [node()], attributes: [:id, :user_id, :token, :access_expires_in]]) do
      {:atomic, :ok} ->

        Mnesia.add_table_index(Token, :user_id)

      {:aborted, {:already_exists, Token}} ->

        check_token_table()

    end
  end

  defp check_token_table() do
    case Mnesia.table_info(Token, :attributes) do
      {:aborted, {:no_exists, Token, :attributes}} -> {:error, :start_mnesia_token, :no_exists}

      [:id, :user_id, :token, :access_expires_in] ->

        Mnesia.wait_for_tables([Token], 5000)


        Mnesia.transform_table(Token,
          fn ({Token, id, user_id, token, access_expires_in}) ->
            {Token, id, user_id, token, access_expires_in, 21}
          end,
          [:id, :user_id, :token, :access_expires_in]
        )

        Mnesia.add_table_index(Token, :user_id)


      other -> {:error, other}
    end
  end


  def write_token(token_id, user_id, token, exp) do
    fn ->
      Mnesia.write({Token, token_id, user_id, token, exp})
    end
    |> Mnesia.transaction()
  end

  def get_token_by_id(id) do
    data_to_read = fn ->
      Mnesia.read({Token, id})
    end

    case Mnesia.transaction(data_to_read) do
      {:atomic,[{Token, id, user_id, token, exp}]} ->
        {:ok, :get_token_by_id, %{id: id, user_id: user_id, token: token, access_expires_in: exp}}

      {:atomic, []} -> {:error, :get_token_by_id, :no_token}

      _ -> {:error, :get_token_by_id, :no_exists}
    end
  end


  def get_token_by_user_id(user_id) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:error, :get_token_by_user_id, :no_token}
      {:atomic, data} -> {:ok, :get_token_by_user_id, data}
      _ -> {:error, :get_token_by_user_id, :no_exists}
    end
  end

end
