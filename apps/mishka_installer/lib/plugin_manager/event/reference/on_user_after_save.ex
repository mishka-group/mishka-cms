defmodule MishkaInstaller.Reference.OnUserAfterSave do
  @moduledoc """
    This event is triggered whenever a user is successfully added or edited. if there is any active module in this section on state,
    this module sends a request as a Task tool to the developer call function that includes `user_info()`, `ip()`, `endpoint()`.
    It should be noted; This process does not interfere with the main operation of the system.
    It is just a sender and is active for both side endpoints.
  """
  defstruct [:user_info, :ip, :endpoint, :status, :conn, :modifier_user, :extra]

  @type modifier_user() :: <<_::288>> | :self
  @type user_info() :: map()
  @type status() :: :added | :edited
  @type conn() :: Plug.Conn.t() | Phoenix.LiveView.Socket.t()
  @type extra() :: map() | struct() | list()
  @type ip() :: String.t() | tuple() # User's IP from both side endpoints connections
  @type endpoint() :: :html | :api # API, HTML
  @type ref() :: :on_user_after_save # Name of this event
  @type reason() :: map() | String.t() # output of state for this event
  @type registerd_info() :: MishkaInstaller.PluginState.t() # information about this plugin on state which was saved
  @type state() :: %__MODULE__{
    user_info: user_info(), ip: ip(), endpoint: endpoint(), status: status(), conn: conn(), modifier_user: modifier_user(), extra: extra()
  }
  @type t :: state() # help developers to keep elixir style
  @type optional_callbacks :: {:ok, ref(), registerd_info()} | {:error, ref(), reason()}

  @callback initial(list()) :: {:ok, ref(), state()} | {:error, ref(), reason()} # Register hook
  @callback call(state()) :: {:reply, state()} | {:reply, :halt, state()}  # Developer should decide what and Hook call function
  @callback stop(registerd_info()) :: optional_callbacks() # Stop of hook module
  @callback restart(registerd_info()) :: optional_callbacks() # Restart of hook module
  @callback start(registerd_info()) :: optional_callbacks() # Start of hook module
  @callback delete(registerd_info()) :: optional_callbacks() # Delete of hook module
  @callback unregister(registerd_info()) :: optional_callbacks() # Unregister of hook module
  @optional_callbacks stop: 1, restart: 1, start: 1, delete: 1, unregister: 1 # Developer can use this callbacks if he/she needs
end
