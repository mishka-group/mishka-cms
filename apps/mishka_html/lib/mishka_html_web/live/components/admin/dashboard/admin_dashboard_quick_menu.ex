defmodule MishkaHtmlWeb.Admin.Dashboard.QuickmenuMenuComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
      <div class="col admin-home-quickmenu-center-block vazir">
        <%# change with phoenix liveview %>
        <div class="row">
          <div class="col"></div>
          <div class="col-sm-6 admin-home-tab">
            <ul class="nav nav-pills mb-3 " id="pills-tab" role="tablist">
              <li class="nav-item " role="presentation">
                <a class="nav-link active" id="tab1-tab" data-bs-toggle="pill" data-bs-target="#tab1" role="tab" aria-controls="tab1" aria-selected="true"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "خانه") %></a>
              </li>
              <li class="nav-item " role="presentation">
                <a class="nav-link" id="tab3-tab" data-bs-toggle="pill" data-bs-target="#tab3" role="tab" aria-controls="tab3" aria-selected="false"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "پشتیبانی") %></a>
              </li>
              <li class="nav-item " role="presentation">
                <a class="nav-link" id="tab2-tab" data-bs-toggle="pill" data-bs-target="#tab2" role="tab" aria-controls="tab2" aria-selected="false"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مدیریت پروژه") %></a>
              </li>
            </ul>
          </div>
          <div class="col"></div>
        </div>



        <div class="clearfix"></div>

        <h3 class="admin-dashbord-h3-right-side-title vazir"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "داشبورد مدیریتی") %></h3>
        <span class="admin-dashbord-right-side-text vazir">
        <%= MishkaTranslator.Gettext.dgettext("html_live_component", "شما در این بخش می توانید به صورت سریع بخش های مختلف از سایت خود را برای مدیریت انتخاب کنید.") %>
        </span>
        <div class="clearfix"></div>
        <div class="col space20"> </div>
        <%# should be into tabs  %>


        <div class="tab-pane fade show active row cms-block-menu">

          <div class="col-sm-3 cms-block-menu-right">
            <%# posts %> <%# posts comments info %> <%# posts like info %>
            <%# categories %>
            <%# seo setting %>

            <div class="create-post-menu text-center" phx-click="blog-posts" phx-target="<%= @myself %>">

              <span class="iconly-bulkEdit">
                <span class="path1"></span><span class="path2"></span><span class="path3"></span>
              </span>

              <div class="clearfix"></div>
              <div class="space10"></div>
              <div class="clearfix"></div>

              <span class="text-center rtl vazir admin-home-create-post-title-text">
              <%= MishkaTranslator.Gettext.dgettext("html_live_component", "مطالب") %>
              </span>
            </div>


            <div class="create-category-menu text-center"  phx-click="blog-categories" phx-target="<%= @myself %>">
              <span class="iconly-bulkEdit">
                <span class="iconly-bulkFolder"><span class="path1"></span><span class="path2"></span></span>
              </span>

              <div class="clearfix"></div>
              <div class="space10"></div>
              <div class="clearfix"></div>

              <span class="text-center rtl vazir admin-home-create-category-title-text" phx-click="blog-categories" phx-target="<%= @myself %>">
              <%= MishkaTranslator.Gettext.dgettext("html_live_component", "مجموعه ها") %>
              </span>
            </div>


            <div class="seo-setting-menu text-center" phx-click="seo-setting" phx-target="<%= @myself %>">
              <span class="iconly-bulkEdit">
                <span class="iconly-bulkShow"><span class="path1"></span><span class="path2"></span></span>
              </span>

              <div class="clearfix"></div>
              <div class="space10"></div>
              <div class="clearfix"></div>

              <span class="text-center rtl vazir admin-home-seo-title-text">
              <%= MishkaTranslator.Gettext.dgettext("html_live_component", "تنظیمات سئو") %>
              </span>
            </div>


          </div>

          <%= live_component @socket, MishkaHtmlWeb.Admin.Dashboard.ActivitiesComponent,
                             id: :admin_activities,
                             activities: @activities
          %>


          <div class="col cms-block-menu-left">
            <%# statics %>
            <div class="container home-admin-users" phx-click="users" phx-target="<%= @myself %>">
              <div class="text-center rtl vazir">
                <span class="iconly-bulkShield-Done"><span class="path1"></span><span class="path2"></span></span>

                <div class="clearfix"></div>
                <div class="space10"></div>
                <div class="clearfix"></div>

                <span class="text-center rtl vazir admin-home-users-text">
                <%= MishkaTranslator.Gettext.dgettext("html_live_component", "مدیریت کاربران") %>
                </span>
                <div class="clearfix"></div>
            </div>
            </div>


            <div class="row left-menu-admin-home"  phx-click="comments" phx-target="<%= @myself %>">
              <div class="col-sm-5 statics-menu float-right comment-home-admin-margin">
                <div class="text-center admin-home-comment-menu rtl vazir">
                  <span class="iconly-bulkChat"><span class="path1"></span><span class="path2"></span></span>

                  <div class="clearfix"></div>
                  <div class="space10"></div>
                  <div class="clearfix"></div>

                  <span class="text-center rtl vazir admin-home-comment-text">
                  <%= MishkaTranslator.Gettext.dgettext("html_live_component", "نظر ها") %>
                  </span>
                  <div class="clearfix"></div>
                </div>
              </div>

              <div class="col-sm-5 statics-menu float-left" phx-click="subscriptions" phx-target="<%= @myself %>">

                <div class="text-center admin-home-sub-menu rtl vazir">
                  <span class="iconly-bulkWallet"><span class="path1"></span><span class="path2"></span><span class="path3"></span></span>

                  <div class="clearfix"></div>
                  <div class="space10"></div>
                  <div class="clearfix"></div>

                  <span class="text-center rtl vazir admin-home-comment-text">
                  <%= MishkaTranslator.Gettext.dgettext("html_live_component", "اشتراک") %>
                  </span>
                  <div class="clearfix"></div>
                </div>

              </div>
            </div>


            <div class="col statics-menu text-center" phx-click="subscriptions" phx-target="<%= @myself %>">
                <div class="text-center admin-home-activity-menu rtl vazir">
                  <span class="iconly-bulkInfo-Square"><span class="path1"></span><span class="path2"></span></span>

                  <div class="clearfix"></div>
                  <div class="space10"></div>
                  <div class="clearfix"></div>

                  <span class="text-center rtl vazir admin-home-comment-text">
                  <%= MishkaTranslator.Gettext.dgettext("html_live_component", "آمار و گزارش ها") %>
                  </span>
                  <div class="clearfix"></div>
                </div>

            </div>
          </div>
          <div class="clearfix"></div>
        </div>
      </div>
    """
  end

  def handle_event("blog-posts", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))}
  end

  def handle_event("blog-categories", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogCategoriesLive))}
  end

  def handle_event("seo-setting", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminSeoLive))}
  end

  def handle_event("users", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))}
  end

  def handle_event("comments", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))}
  end

  def handle_event("subscriptions", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminSubscriptionsLive))}
  end
end
