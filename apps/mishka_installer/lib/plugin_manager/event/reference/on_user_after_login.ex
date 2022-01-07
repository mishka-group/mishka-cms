defmodule MishkaInstaller.Reference.OnUserAfterLogin do

  defstruct [:user_basic_info, :user_permission, :endpoint, :type]

  @type user_id() :: Ecto.UUID.t
  @type user_info() :: map()
  @type user_permission() :: list()
  @type endpoint() :: atom()
  @type type() :: atom()
  @type ref() :: :on_user_after_login
  @type new_state() :: map()
  @type reason() :: map()
  @type registerd_info() :: map()

  @callback init(list()) :: {:ok, ref(), new_state} | {:error, ref(), reason()}
  @callback call(user_info(), user_permission(), endpoint(), type()) :: {:ok, ref(), new_state} | {:error, ref(), reason()}
  @callback stop(registerd_info()) :: {:ok, ref(), new_state} | {:error, ref(), reason()}
  @callback restart(registerd_info()) :: {:ok, ref(), new_state} | {:error, ref(), reason()}
  # Because the plugins manager has own stop, restart module, it was unnecessary to be a @callback, so if developer wants to do more,
  # use these callback, it should be noted the system bind theire first priority
  @optional_callbacks stop: 1, restart: 1
end
