defmodule MishkaContentTest.SubscriptionTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase

  alias MishkaContent.General.Subscription

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  @right_user_info %{
    "full_name" => "username",
    "username" => "usernameuniq_#{Enum.random(100_000..999_999)}",
    "email" => "user_name_#{Enum.random(100_000..999_999)}@gmail.com",
    "password" => "pass1Test",
    "status" => 1,
    "unconfirmed_email" => "user_name_#{Enum.random(100_000..999_999)}@gmail.com"
  }

  @subscription_info %{
    status: :active,
    section: :blog_post,
    section_id: Ecto.UUID.generate(),
    expire_time: DateTime.utc_now(),
    extra: %{test: "this is a test of Subscription"}
  }

  setup _context do
    {:ok, :add, :user, user_info} = MishkaUser.User.create(@right_user_info)
    {:ok, user_info: user_info}
  end

  describe "Happy | subscription CRUD DB (▰˘◡˘▰)" do
    test "create a subscription", context do
      {:ok, :add, :subscription, _subscription_info} =
        assert Subscription.create(
                 Map.merge(@subscription_info, %{user_id: context.user_info.id})
               )
    end

    test "edit a subscription", context do
      {:ok, :add, :subscription, subscription_info} =
        assert Subscription.create(
                 Map.merge(@subscription_info, %{user_id: context.user_info.id})
               )

      {:ok, :edit, :subscription, _subscription_info} =
        assert Subscription.edit(
                 Map.merge(@subscription_info, %{
                   id: subscription_info.id,
                   extra: %{test: "test Subscription 2"}
                 })
               )
    end

    test "delete a subscription", context do
      {:ok, :add, :subscription, subscription_info} =
        assert Subscription.create(
                 Map.merge(@subscription_info, %{user_id: context.user_info.id})
               )

      {:ok, :delete, :subscription, _subscription_info} =
        assert Subscription.delete(subscription_info.id)
    end

    test "show by id", context do
      {:ok, :add, :subscription, subscription_info} =
        assert Subscription.create(
                 Map.merge(@subscription_info, %{user_id: context.user_info.id})
               )

      {:ok, :get_record_by_id, :subscription, _subscription_info} =
        assert Subscription.show_by_id(subscription_info.id)
    end

    test "show user subscriptions", context do
      {:ok, :add, :subscription, subscription_info} =
        assert Subscription.create(
                 Map.merge(@subscription_info, %{user_id: context.user_info.id})
               )

      1 =
        assert length(
                 Subscription.subscriptions(
                   conditions: {1, 10},
                   filters: %{user_id: subscription_info.user_id}
                 ).entries
               )

      1 = assert length(Subscription.subscriptions(conditions: {1, 10}, filters: %{}).entries)
    end
  end

  describe "UnHappy | subscription CRUD DB ಠ╭╮ಠ" do
    test "show user subscriptions", context do
      0 =
        assert length(
                 Subscription.subscriptions(
                   conditions: {1, 10},
                   filters: %{user_id: context.user_info.id}
                 ).entries
               )

      0 = assert length(Subscription.subscriptions(conditions: {1, 10}, filters: %{}).entries)
    end

    test "create a subscription", context do
      {:error, :add, :subscription, _subscription_info} =
        assert Subscription.create(%{user_id: context.user_info.id})
    end
  end
end
