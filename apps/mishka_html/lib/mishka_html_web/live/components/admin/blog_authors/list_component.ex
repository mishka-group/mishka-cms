defmodule MishkaHtmlWeb.Admin.BlogAuthors.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col-sm-1 titile-of-blog-posts alert alert-primary" id="div-image">
                    تصویر
                </div>

                <div class="col-sm-2 titile-of-blog-posts alert alert-warning" id="div-full_name">
                    نام کامل
                </div>

                <div class="col titile-of-blog-posts alert alert-success" id="div-insert">
                    ثبت
                </div>

                <div class="col titile-of-blog-posts alert alert-info" id="div-update">
                    به روز رسانی
                </div>

                <div class="col-sm-3 titile-of-blog-posts alert alert-dark" id="div-opreation">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {item, color} <- Enum.zip(@authors, Stream.cycle(["wlist", "glist"])) do %>
                <div phx-update="append" id="<%= item.id %>" class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">

                    <div class="col-sm-1" id="<%= "user_image-#{item.id}" %>">
                        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" class="bi bi-cup" viewBox="0 0 16 16">
                            <path d="M1 2a1 1 0 0 1 1-1h11a1 1 0 0 1 1 1v1h.5A1.5 1.5 0 0 1 16 4.5v7a1.5 1.5 0 0 1-1.5 1.5h-.55a2.5 2.5 0 0 1-2.45 2h-8A2.5 2.5 0 0 1 1 12.5V2zm13 10h.5a.5.5 0 0 0 .5-.5v-7a.5.5 0 0 0-.5-.5H14v8zM13 2H2v10.5A1.5 1.5 0 0 0 3.5 14h8a1.5 1.5 0 0 0 1.5-1.5V2z"/>
                        </svg>
                    </div>

                    <div class="col-sm-2" id="<%= "user-full-name-#{item.id}" %>">
                        <%= live_redirect "#{item.user_full_name}",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.user_id)
                        %>
                    </div>

                    <div class="col" id="<%= "inserted-#{item.id}" %>">
                        <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "inserted-#{item.id}-component",
                            time: item.inserted_at
                        %>
                    </div>

                    <div class="col" id="<%= "updated-#{item.id}" %>">
                        <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "updated-#{item.id}-component",
                            time: item.updated_at
                        %>
                    </div>

                    <div class="col-sm-3 opration-post-blog" id="<%= "opration-#{item.id}" %>">
                        <a class="btn btn-outline-primary vazir",
                                phx-click="delete"
                                phx-value-id="<%= item.id %>">حذف</a>

                    </div>
                </div>
                <div class="space20"></div>
                <div class="clearfix"></div>
            <% end %>
        </div>

      </div>
    """
  end
end
