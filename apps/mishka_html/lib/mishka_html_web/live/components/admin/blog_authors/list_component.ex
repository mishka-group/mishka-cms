defmodule MishkaHtmlWeb.Admin.BlogAuthors.ListComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="table-responsive">
            <table class="table vazir">
                <thead>
                    <tr>
                        <th scope="col td-allert warning" id="div-image"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تصویر") %></th>
                        <th scope="col" id="div-title"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نام کامل") %></th>
                        <th scope="col" id="div-priority"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ثبت") %></th>
                        <th scope="col" id="div-status"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "به روز رسانی") %></th>
                        <th scope="col" id="div-opration"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عملیات") %></th>
                    </tr>
                </thead>
                <tbody>
                    <%= for {item, color} <- Enum.zip(@authors, Stream.cycle(["wlist", "glist"])) do %>
                    <tr class="blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                        <td class="align-middle text-center" id="<%= "title-#{item.id}" %>">
                            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" class="bi bi-cup" viewBox="0 0 16 16">
                            <path d="M1 2a1 1 0 0 1 1-1h11a1 1 0 0 1 1 1v1h.5A1.5 1.5 0 0 1 16 4.5v7a1.5 1.5 0 0 1-1.5 1.5h-.55a2.5 2.5 0 0 1-2.45 2h-8A2.5 2.5 0 0 1 1 12.5V2zm13 10h.5a.5.5 0 0 0 .5-.5v-7a.5.5 0 0 0-.5-.5H14v8zM13 2H2v10.5A1.5 1.5 0 0 0 3.5 14h8a1.5 1.5 0 0 0 1.5-1.5V2z"/>
                            </svg>
                        </td>
                        <td class="align-middle text-center">
                            <%= live_redirect "#{MishkaHtml.full_name_sanitize(item.user_full_name)}",
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.user_id)
                            %>
                        </td>
                        <td class="align-middle text-center">
                            <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "inserted-#{item.id}-component",
                            time: item.inserted_at
                            %>
                        </td>
                        <td class="align-middle text-center">
                            <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "updated_at-#{item.id}-component",
                            time: item.updated_at
                            %>
                        </td>
                        <td  class="align-middle text-center" id="<%= "opration-#{item.id}" %>">
                            <a class="btn btn-outline-primary vazir", phx-click="delete" phx-value-id="<%= item.id %>"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "حذف") %></a>
                        </td>
                    </tr>
                    <% end %>
                </tbody>
            </table>
        </div>

      </div>
    """
  end
end
