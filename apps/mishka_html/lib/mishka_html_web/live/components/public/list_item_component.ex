defmodule MishkaHtml.Helpers.ListItemComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="col bw admin-blog-post-list" id={@id}>
        <div class="table-responsive">
            <table class="table vazir">
                <thead>
                    <tr>
                        <%= for item <- get_list_headers(@fields) do %>
                            <th scope="col" class={"list-component-header-item #{item.class}"} id={Map.get(item, :id) || Ecto.UUID.generate}>
                                <%= item.title %>
                            </th>
                        <% end %>
                        <th scope="col" class="col list-component-header-item header6">
                            عملیات
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <%= for {list_item, color} <- Enum.zip(@list, Stream.cycle(["wlist", "glist"])) do %>
                    <tr id={Map.get(list_item, :id) || Ecto.UUID.generate} class={"list-component-item #{if(color == "glist", do: "odd-list-of-blog-posts align-middle", else: "align-middle")}"}>
                        <%= for field_item <- get_list_headers(@fields) do %>
                            <td class="col list-item-value">
                                <%= if field_item.form == "custom" do %>
                                    <%= convert_value_to_list_html(field_item, assigns, field_item.html, list_item) %>
                                <% else %>
                                    <%= convert_value_to_list_html(field_item, assigns, Map.get(list_item, String.to_atom(field_item.type)), list_item) %>
                                <% end %>
                            </td>
                        <% end %>
                        <td  class="list-component-links-item align-middle" id={"opration-#{list_item.id}"}>
                            <%= for {item, index} <- Enum.with_index(@section_info.section_btns.list_item) do %>
                                <%= list_item_btn(item.method, list_item, assigns, item) %>
                                <%= if index == 2 do %>
                                    <div class="space10"></div>
                                    <div class="clearfix"></div>
                                <% end %>
                            <% end %>
                            <%= if custom_operations = Map.get(@section_info, :custom_operations) do %>
                                <%= @url.custom_operations(assigns, Map.take(list_item, custom_operations), @parent_assigns) %>
                            <% end %>
                        </td>
                    </tr>
                    <% end %>
                </tbody>
            </table>
            <div class="space20"></div>
            <div class="col-sm-10">
                <%= if is_map(@list) and  @list.entries != [] do %>
                    <.live_component module={MishkaHtmlWeb.Public.PaginationComponent} id={:pagination} pagination_url={@url} data={@list} filters={@filters} count={@count} />
                <% end %>
            </div>
        </div>
    </div>
    """
  end

  # This duplicated code exists in my project because I want to create a space for my new clients to see a clear code
  def text_field(type, statuses, custom_class, title, {header, input, search}, validation \\ nil) do
    %{
      type: type,
      status: Enum.map(fetch_statuses(statuses), fn {_id, item} -> item end),
      form: "text",
      class: custom_class,
      title: title,
      header: header,
      input: input,
      search: search,
      validation: validation
    }
  end

  def select_field(type, statuses, custom_class, title, options, {header, input, search}) do
    text_field(type, statuses, custom_class, title, {header, input, search})
    |> Map.merge(%{options: options, form: "select"})
  end

  def add_tag_field(type, statuses, custom_class, title, {header, input, search}) do
    text_field(type, statuses, custom_class, title, {header, input, search})
    |> Map.merge(%{form: "add_tag"})
  end

  def editor_field(
        type,
        statuses,
        custom_class,
        title,
        {header, input, search},
        validation \\ nil
      ) do
    text_field(type, statuses, custom_class, title, {header, input, search}, validation)
    |> Map.merge(%{form: "editor"})
  end

  def textarea_field(
        type,
        statuses,
        custom_class,
        title,
        {header, input, search},
        validation \\ nil
      ) do
    text_field(type, statuses, custom_class, title, {header, input, search}, validation)
    |> Map.merge(%{form: "textarea"})
  end

  def upload_field(type, statuses, custom_class, title, {header, input, search}) do
    text_field(type, statuses, custom_class, title, {header, input, search})
    |> Map.merge(%{form: "upload"})
  end

  def text_search_field(type, statuses, custom_class, title, {header, input, search}) do
    text_field(type, statuses, custom_class, title, {header, input, search})
    |> Map.merge(%{form: "text_search"})
  end

  def time_field(type, statuses, custom_class, title, detail, {header, input, search}) do
    text_field(type, statuses, custom_class, title, {header, input, search})
    |> Map.merge(%{form: "time", time_detail: detail})
  end

  def link_field(
        type,
        statuses,
        custom_class,
        title,
        {router, action},
        {header, input, search},
        validation \\ nil
      ) do
    text_field(type, statuses, custom_class, title, {header, input, search}, validation)
    |> Map.merge(%{form: "link", router: router, action: action})
  end

  def custom_field(type, statuses, custom_class, title, html, {header, input, search}) do
    text_field(type, statuses, custom_class, title, {header, input, search})
    |> Map.merge(%{form: "custom", html: html})
  end

  def fetch_statuses(requested_list) when is_integer(requested_list),
    do: fetch_statuses([requested_list])

  def fetch_statuses(requested_list) do
    Enum.filter(statuses(), fn {id, _item} -> id in requested_list end)
  end

  def statuses() do
    [
      {1,
       %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}},
      {2,
       %{title: MishkaTranslator.Gettext.dgettext("html_live", "یکتا"), class: "badge bg-success"}},
      {3,
       %{
         title: MishkaTranslator.Gettext.dgettext("html_live", "غیر ضروری"),
         class: "badge bg-info"
       }},
      {4,
       %{
         title: MishkaTranslator.Gettext.dgettext("html_live", "پیشنهادی"),
         class: "badge bg-dark"
       }},
      {5,
       %{
         title: MishkaTranslator.Gettext.dgettext("html_live", "غیر پیشنهادی"),
         class: "badge bg-warning"
       }},
      {6,
       %{
         title: MishkaTranslator.Gettext.dgettext("html_live", "هشدار"),
         class: "badge bg-secondary"
       }}
    ]
  end

  def convert_value_to_list_html(field_item, assigns, value, _list_item)
      when field_item.form == "upload" do
    ~H"""
        <span class="list-img">
            <img src={value} alt={field_item.title} >
        </span>
    """
  end

  def convert_value_to_list_html(field_item, assigns, value, _list_item)
      when field_item.form == "select" do
    # We do not consider nil value to show developer that his/her options have problem and are not same with database
    {translated, _value} =
      Enum.find(field_item.options, fn {_translated, item_value} ->
        item_value == Atom.to_string(value)
      end)

    ~H"""
        <%= translated %>
    """
  end

  def convert_value_to_list_html(field_item, assigns, value, list_item)
      when field_item.form == "link" do
    ~H"""
        <%= if is_nil(Map.get(list_item, field_item.action)) do %>
            <%= MishkaTranslator.Gettext.dgettext("html_live", "ندارد") %>
        <% else %>
            <%= live_redirect value_validation_preparing(field_item.validation, value),
            to: Routes.live_path(@socket, field_item.router, id: Map.get(list_item, field_item.action)),
            class: "list-link"
            %>
        <% end %>
    """
  end

  def convert_value_to_list_html(field_item, assigns, value, _list_item)
      when field_item.form == "time" and not is_nil(value) do
    component_id = Ecto.UUID.generate()

    ~H"""
        <.live_component
            module={MishkaHtmlWeb.Helpers.TimeConverterComponent}
            id={"DateTime_component_#{component_id}"}
            span_id={"DateTime_component_#{component_id}"}
            time={value},
            detail={field_item.time_detail}
        />
    """
  end

  def convert_value_to_list_html(field_item, _assigns, _value, _list_item)
      when field_item.form == "time",
      do: MishkaTranslator.Gettext.dgettext("html_live", "ندارد")

  def convert_value_to_list_html(field_item, assigns, value, _list_item)
      when field_item.form == "custom" do
    ~H"""
        <%= raw(value) %>
    """
  end

  def convert_value_to_list_html(field_item, assigns, value, _list_item) do
    ~H"""
        <%= value_validation_preparing(field_item.validation, value) %>
    """
  end

  defp value_validation_preparing(nil, value) do
    value
  end

  defp value_validation_preparing(validation, value) do
    validation.(value)
  end

  def get_list_headers(fields) do
    fields
    |> Enum.filter(fn field -> field.header end)
  end

  def list_item_btn(:delete, list_item, assigns, btn_item) do
    ~H"""
        <a class={btn_item.class} phx-click="delete" phx-value-id={list_item.id}><%= btn_item.title %></a>
    """
  end

  def list_item_btn(:redirect, list_item, assigns, btn_item) do
    ~H"""
        <%= live_redirect btn_item.title, to: Routes.live_path(@socket, btn_item.router, Map.get(list_item, btn_item.action)), class: btn_item.class %>
    """
  end

  def list_item_btn(:redirect_key, list_item, assigns, btn_item) do
    ~H"""
        <%= live_redirect btn_item.title, to: Routes.live_path(@socket, btn_item.router, "#{Map.get(btn_item, :key) || btn_item.action}": Map.get(list_item, btn_item.action)), class: btn_item.class %>
    """
  end

  def list_item_btn(:redirect_keys, list_item, assigns, btn_item) do
    router_path = Enum.find(btn_item.keys, fn {key, _value} -> key == :without_key end)

    get_btns =
      Enum.map(btn_item.keys, fn {key, value} = list ->
        cond do
          list == {:without_key, value} -> []
          is_bitstring(value) -> ["#{key}": value]
          true -> ["#{key}": Map.get(list_item, value)]
        end
      end)
      |> Enum.filter(&(!is_nil(&1)))
      |> Enum.concat()

    ~H"""
        <%= if is_nil(router_path) do %>
            <%= live_redirect btn_item.title, to: Routes.live_path(@socket, btn_item.router, get_btns), class: btn_item.class %>
        <% else %>
            <% {:without_key, value} = router_path %>
            <%= live_redirect btn_item.title, to: Routes.live_path(@socket, btn_item.router, value, get_btns), class: btn_item.class %>
        <% end %>
    """
  end
end
