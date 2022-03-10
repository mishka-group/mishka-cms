defmodule MishkaInstaller.Reference.OnUserAuthorisationFailure do
  @moduledoc """
    This event is triggered whenever a user gets an error for authorisation. if there is any active module in this section on state,
    this module sends a request as a Task tool to the developer call function that includes `extra()`, `ip()`, `endpoint()`.
    It should be noted; This process does not interfere with the main operation of the system.
    It is just a sender and is active for both side endpoints.
  """
  defstruct [:conn, :ip, :endpoint, :error, :module, :operation, :extra]

  @type extra() :: map() | struct() | list()
  @type error() :: map() | struct() | tuple()
  @type conn() :: Plug.Conn.t() | Phoenix.LiveView.Socket.t()
  @type ip() :: String.t() | tuple() # User's IP from both side endpoints connections
  @type endpoint() :: atom() # API, HTML
  @type operation() :: atom()
  @type ref() :: :on_user_authorisation_failure # Name of this event
  @type reason() :: map() | String.t() # output of state for this event
  @type registerd_info() :: MishkaInstaller.PluginState.t() # information about this plugin on state which was saved
  @type state() :: %__MODULE__{conn: conn(), ip: ip(), endpoint: endpoint(), error: error(), module: module(), operation: operation(), extra: extra()}
  @type t :: state() # help developers to keep elixir style
  @type optional_callbacks :: {:ok, ref(), registerd_info()} | {:error, ref(), reason()}

  @callback initial(list()) :: {:ok, ref(), list()} | {:error, ref(), reason()} # Register hook
  @callback call(state()) :: {:reply, state()} | {:reply, :halt, state()}  # Developer should decide what and Hook call function
  @callback stop(registerd_info()) :: optional_callbacks() # Stop of hook module
  @callback restart(registerd_info()) :: optional_callbacks() # Restart of hook module
  @callback start(registerd_info()) :: optional_callbacks() # Start of hook module
  @callback delete(registerd_info()) :: optional_callbacks() # Delete of hook module
  @callback unregister(registerd_info()) :: optional_callbacks() # Unregister of hook module
  @optional_callbacks stop: 1, restart: 1, start: 1, delete: 1, unregister: 1 # Developer can use this callbacks if he/she needs
end
