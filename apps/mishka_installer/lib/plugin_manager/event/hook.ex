defmodule MishkaInstaller.Hook do

  #### Starting Priority Check ####
  # if a package has a hight priority like 100 and there are 3 more package
  # if there is no `depends` for this packages, Then start with the lowest priority, and pass theire `{:reply, new_state}` to higher
  # than before.
  # but if `depends` for each of thease packages exists, then check if the specific package is loaded or not! if not `{:noreply, :halt}`
  # if yes use `{:reply, new_state}`
  # it should be noted, any package that wants to be stopped in this way just loads `{:noreply, :halt}`, after doing this, the higher
  # priority plugins are not loaded or run
  # Hook just needs to load :started status
  #### Finishing Priority Check ####

  # TODO: register a module
  def register() do
    {:ok, :register}
  end

  # TODO: start a module
  def start() do
    {:ok, :stop}
  end

  # TODO: restart a module
  def restart() do
    {:ok, :reset}
  end

  # TODO: stop a module
  def stop() do
    {:ok, :stop}
  end

  def call() do
    {:ok, :call}
  end

  def delete() do
    {:ok, :delete}
  end

  # TODO: validate each module output and allowed_input
  def check_priority_of_events_registerd() do
    {:ok, :check_priority_of_events_registerd}
  end
end
