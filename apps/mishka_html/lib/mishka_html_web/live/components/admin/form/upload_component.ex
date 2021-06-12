defmodule MishkaHtmlWeb.Admin.Form.UploadComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="col-sm-6 admin-upload-form">
      <div class="drop" phx-drop-target="<%= @ref %>">
          <button phx-click="delete_form" phx-value-type="<%= @form_type %>" type="button" class="btn-close" aria-label="Close"></button>

          <div class="form-error-tag">
            <%= error_tag @f, String.to_atom(@form_type) %>
          </div>

          <div class="clearfix"></div>
          <div class="space30"></div>
          <div class="hint">
          <span class="badge bg-dark">
              Add up to <%= @max_entries %> avatar
              (max <%= @max_file_size %> MB each)
          </span>
          </div>

          <div class="clearfix"></div>
          <div class="space40"></div>
          <div class="col-sm-8 mx-auto">
              <%= live_file_input @live_file_input, class: "form-control form-control-lg" %>
          </div>
          <div class="clearfix"></div>
          <div class="space10"></div>
          <span class="text-muted">یا فایل را بکشید و اینجا رها کنید.</span>
          <div class="clearfix"></div>
          <div class="space30"></div>

          <%= for {_ref, err} <- @errors do %>
          <div class="error">
          <%= humanize(err) %>
          </div>
          <% end %>

          <div class="row mx-auto">
          <div class="clearfix"></div>
          <div class="space30"></div>
              <%= for {entry, color} <- Enum.zip(@entries, Stream.cycle(["success", "info", "warning", "danger"])) do %>
                  <div class="entry col-sm-3 ">

                  <div class="admin-upload-img-form ">
                      <%= live_img_preview entry %>

                      <div class="clearfix"></div>
                      <div class="space10"></div>

                      <div class="progress admin-upload-form-progress">
                          <div class="progress-bar progress-bar-striped bg-<%= color %>"
                              role="progressbar"
                              style="width: <%= entry.progress %>%"
                              aria-valuenow="<%= entry.progress %>%"
                              aria-valuemin="0"
                              aria-valuemax="100">
                              <%= entry.progress %>%
                          </div>
                      </div>

                      <a href="#" phx-click="cancel-upload" phx-value-ref="<%= entry.ref %>" phx-value-upload_field="<%= @upload_field %>" class="col-sm-2">&times;</a>
                  </div>


                  <%= for err <- upload_errors(@upload_errors, entry) do %>
                      <div class="error">
                      <%= humanize(err) %>
                      </div>
                  <% end %>
                  </div>
              <% end %>
          </div>
      </div>
    </div>
    """
  end
end
