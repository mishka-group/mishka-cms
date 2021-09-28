defmodule MishkaHtmlWeb.AdminSubscriptionsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Subscription
  alias MishkaHtmlWeb.Admin.Subscription.DeleteErrorComponent

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Subscription,
      redirect: __MODULE__,
      router: Routes,
      skip_list: ["full_name"]

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminSubscriptionView, "admin_subscriptions_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Subscription.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        user_id: Map.get(session, "user_id"),
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت اشتراک ها"),
        body_color: "#a29ac3cf",
        subscriptions: Subscription.subscriptions(conditions: {1, 10}, filters: %{})
      )

      {:ok, socket, temporary_assigns: [subscriptions: []]}
  end

  # Live CRUD
  paginate(:subscriptions, user_id: false)

  list_search_and_action()

  delete_list_item(:subscriptions, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminSubscriptionsLive")

  update_list(:subscriptions, false)
end
