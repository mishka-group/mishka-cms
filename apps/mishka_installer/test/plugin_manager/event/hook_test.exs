defmodule MishkaInstallerTest.Event.HookTest do
  use ExUnit.Case, async: true
  doctest MishkaInstaller

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  describe "Happy | Plugin Hook (▰˘◡˘▰)" do

  end

  describe "UnHappy | Plugin Hook ಠ╭╮ಠ" do

  end
end
