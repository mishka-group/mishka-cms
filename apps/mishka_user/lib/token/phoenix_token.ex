defmodule MishkaUser.Token.PhoenixToken do
  alias MishkaUser.Token.TokenManagemnt

  @refresh_token_time 2000 #should be changed
  @access_token_time 2000 #should be changed
  @hard_secret_refresh "Test refresh"
  @hard_secret_access "Test access"
  # ["access", "refresh", "current"]


  # create a token with Phoenix token by type
  def create_token(id, :access) do
    token = Phoenix.Token.sign(MishkaApiWeb.Endpoint, @hard_secret_access, %{id: id}, [key_digest: :sha256])
    # call the save_token function to store token on user node Genserver
    {:ok, :access, token}
  end

  def create_token(id, :refresh) do
    token = Phoenix.Token.sign(MishkaApiWeb.Endpoint, @hard_secret_refresh, %{id: id}, [key_digest: :sha256])
    # call the save_token function to store token on user node Genserver
    {:ok, :refresh, token}
  end

  # add create_token(id, params, :current)


  # because there is no function to refresh these way
  # verify user sent refresh token
  # delete old token on otp and disk if there is a db more delete on it
  # create a new refresh token if we had a old refresh token on db
  # if we have no old token on state which is refresh token  just show the error with error tag and action
  # re-search how to use it on plug and get header to pass all the router we neede
  def refresh_token(token) do
    verify_token(token, :refresh)
    |> delete_old_token(token)
    |> create_new_refresh_token()
  end

  defp delete_old_token({:ok, :verify_token, :refresh, clime}, _token) do
    # if state of verify is oky, then get it on user GenServer state
    # if there isnt any item on it please call this function with :error header
    # if there is a recorde same user sent token, then delete it
    # call the create_new_refresh_token with custom status
    {:ok, :delete_old_token, clime}
  end

  defp delete_old_token({:error, error_function, :refresh, action}, _token) do
    # when we use this function that we should show verify error, not the exist value of delete_old_token
    # for showing the errors of delete_old_token  call the create_new_refresh_token with :error status
    # call the create_new_refresh_token with :error status
    {:error, error_function, action}
  end


  defp create_new_refresh_token({:ok, :delete_old_token, clime}) do
    # after create_token and those works create a new refresh_token
    # save it on GenServer state and save other location we demonstrate
    # and pass refresh_token function as main error handler
    create_token(clime.id, :refresh) # create a new refresh token
    create_token(clime.id, :access) # create a new access token
    # after the time we seletced for access token it will be deleted
    # I think this is not important to delete all the access token
    # when the refresh token deleted for security reson, but why it can be public
    # if create a function to delete all the access token which is related to the refresh token selected
  end

  defp create_new_refresh_token({:error, error_function, action}) do
    # show last errors with action and fucntion and main function I mean refresh_token as the error handler
    {:error, error_function, :refresh, action}
  end


  def verify_token(token, :refresh) do
    Phoenix.Token.verify(MishkaApiWeb.Endpoint, @hard_secret_refresh, token, [max_age: @refresh_token_time])
    |> case do
      {:ok, clime} -> {:ok, :verify_token, :refresh, clime}
      {:error, action} -> {:error, :verify_token, :refresh, action}
    end
  end

  def verify_token(token, :access) do
    Phoenix.Token.verify(MishkaApiWeb.Endpoint, @hard_secret_access, token, [max_age: @access_token_time])
    |> case do
      {:ok, clime} -> {:ok, :verify_token, :access, clime}
      {:error, action} -> {:error, :verify_token, :access, action}
    end
  end

  def create_refresh_acsses_token(refresh_token) do
    refresh_token(refresh_token)
  end

  def get_refresh_and_access_token do

  end

  def save_token do
    # create a handelinfo to delete token after expire time
    # if the token is access, should have refresh token id,
    # which helps us to delete after refreshtin token or delete the refresh token
  end
end
