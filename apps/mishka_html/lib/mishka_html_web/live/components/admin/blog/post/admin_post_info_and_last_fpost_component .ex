defmodule MishkaHtmlWeb.Admin.Blog.PostInfoAndlastFpostComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="space20"></div>
      <div class="clearfix"></div>
      <div class="row">
          <div class="col">
              <h3 class="admin-dashbord-h3-right-side-title vazir">مدیریت مطالب</h3>
              <span class="admin-dashbord-right-side-text vazir">
              شما در این بخش می توانید مطالب ارسالی در سایت را مدیریت و ویرایش نمایید.
              </span>
              <div class="space20"></div>
              <hr>
              <div class="space40"></div>
              <h3 class="admin-dashbord-h3-right-side-title vazir">مطالب ویژه</h3>
              <span class="admin-dashbord-right-side-text vazir">
              در این بخش می توانید چند مطلب ویژه آخر را ببنید برای دیدن کلیه مطالب ویژه از فیلد های جستجو استفاده کنید.
              </span>
              <div class="space30"></div>
              <div class="row">
                  <div class="col-sm-2" style="
                      background-image: url(../images/test2.jpg);
                      background-repeat: no-repeat;
                      box-shadow: 1px 1px 8px #dadada;
                      background-size: cover;
                      min-height: 100px;
                      margin: 10px;
                  "></div>

                  <div class="col-sm-2" style="
                      background-image: url(../images/test3.jpg);
                      background-repeat: no-repeat;
                      box-shadow: 1px 1px 8px #dadada;
                      background-size: cover;
                      min-height: 100px;
                      margin: 10px;
                  "></div>

                  <div class="col-sm-2" style="
                      background-image: url(../images/test1.jpg);
                      background-repeat: no-repeat;
                      box-shadow: 1px 1px 8px #dadada;
                      background-size: cover;
                      min-height: 100px;
                      margin: 10px;
                  "></div>

                  <div class="col-sm-2" style="
                      background-image: url(../images/test1.jpg);
                      background-repeat: no-repeat;
                      box-shadow: 1px 1px 8px #dadada;
                      background-size: cover;
                      min-height: 100px;
                      margin: 10px;
                  "></div>

                  <div class="col-sm-2" style="
                      background-image: url(../images/test3.jpg);
                      background-repeat: no-repeat;
                      box-shadow: 1px 1px 8px #dadada;
                      background-size: cover;
                      min-height: 100px;
                      margin: 10px;
                  "></div>
              </div>
          </div>


          <%= live_component @socket, MishkaHtmlWeb.Admin.Blog.LastActivitiesComponent , id: :admin_last_actiities %>

      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
