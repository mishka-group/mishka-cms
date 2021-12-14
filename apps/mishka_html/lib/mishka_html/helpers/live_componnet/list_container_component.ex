defmodule MishkaHtml.Helpers.ListContainerComponent do
  use MishkaHtmlWeb, :live_component
  # 1. every component has an @id then we can use its id in the main container
  # 2. @section_btns should be a list that has 2 map items to create btn for every list and header of list container
  # 3. @section_info has two parameters to describe in template like [title and description]
  # 4. @filters passes some value to use on test and pagination
  # 5. @list is the main content to show in the page list
  # 6. @url is a reference to use in the redirect and show what fields we want to usher in a list has three parameters [section_fields, page_size, itself(url)]
  # 7. the fields we want to use on our search
  # 8. we should find a way to implement every list buttons
  # 9. @left_header_side needs a block code to show something like user activities
  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
      <div id={@id}>
        <div class="container main-admin rtl">
          <div class="col admin-main-block-dashboard">
            <div class="row admin-top-page-navigate">
              <div class="col-sm-5 top-back-admin-menue">
              <%= @admin_menu %>
              </div>
              <div class="col vazir text-start top-post-btn">
                <%= for item <- @section_info.section_btns.header do %>
                  <%= live_redirect item.title, to: item.router, class: "#{item.class}" %>
                <% end %>
              </div>
            </div>
            <div class="space20"></div>
            <div class="clearfix"></div>
            <div class="row">
              <div class="col">
                <h3 class="admin-dashbord-h3-right-side-title vazir"><%= @section_info.title %></h3>
                <div class="space20"></div>
                <span class="admin-dashbord-right-side-text vazir"><%= @section_info.description %></span>
              </div>
              <%= @left_header_side %>
              <div class="space20"></div>
            </div>
            <.live_component module={MishkaHtml.Helpers.FlashComponent} id={:live_flash} flash={@flash} />
            <.live_component module={MishkaHtml.Helpers.SearchComponent} id={:search_filters} filters={@filters}, fields={@url.section_fields()} />
            <div class="clearfix"></div>
            <div class="col space30"> </div>
            <.live_component module={MishkaHtml.Helpers.ListItemComponent}
              id={:records_list}
              list={@list}
              filters={@filters}
              count={@page_size}
              url={@url},
              parent_assigns={@parent_assigns}
              fields={@url.section_fields()}
              section_info={@section_info}
            />
          </div>
        </div>
        <div class="clearfix"></div>
        <%= live_render(@socket, MishkaHtml.Helpers.Notif, id: :notif) %>
      </div>
    """
  end
end
