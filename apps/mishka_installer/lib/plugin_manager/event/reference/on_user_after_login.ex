defmodule MishkaInstaller.Reference.OnUserAfterLogin do
  @moduledoc """
    This event is triggered whenever a user is successfully logged in. if there is any active module in this section on state,
    this module sends a request as a Task tool to the developer call function that includes `user_info()`, `ip()`, `endpoint()` , `type()`.
    It should be noted; This process does not interfere with the main operation of the system.
    It is just a sender and is active for both side endpoints.
  """
  defstruct [:user_info, :ip, :endpoint, :status]

  @type user_id() :: Ecto.UUID.t
  @type user_info() :: map()
  @type ip() :: String.t() # User's IP from both side endpoints connections
  @type endpoint() :: atom() # API, HTML
  @type status() :: :started | :stopped | :restarted
  @type ref() :: :on_user_after_login # Name of this plugin
  @type new_state() :: %{user_info: user_info(), ip: ip(), endpoint: endpoint(), status: status()}
  @type reason() :: map()
  @type registerd_info() :: MishkaInstaller.PluginState.t() # information about this plugin on state which was saved

  @type call() :: %__MODULE__{user_info: user_info(), ip: ip(), endpoint: endpoint(), status: status()}
  @type t :: call()

  @callback initial(list()) :: {:ok, ref(), new_state} | {:error, ref(), reason()}
  @callback call(call()) :: {:reply, new_state()} | {:noreply, :halt}  # Developer should decide what
  @callback stop(registerd_info()) :: {:ok, ref(), new_state} | {:error, ref(), reason()}
  @callback restart(registerd_info()) :: {:ok, ref(), new_state} | {:error, ref(), reason()}
  @optional_callbacks stop: 1, restart: 1
end
