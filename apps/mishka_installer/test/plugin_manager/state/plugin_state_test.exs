defmodule MishkaInstallerTest.State.PluginStateTest do
  use ExUnit.Case, async: true
  doctest MishkaInstaller

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  describe "Happy | Plugin State (▰˘◡˘▰)" do

  end

  describe "UnHappy | Plugin State ಠ╭╮ಠ" do

  end
end
