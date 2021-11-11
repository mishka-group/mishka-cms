defmodule MishkaHtmlWeb.Admin.Form.UploadComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~H"""
        <div class="col-sm-6 admin-upload-form vazir">
        <%= label @f , "#{@search_fields.title}:" %>
        <div class="drop" phx-drop-target={@ref}>
            <button phx-click="delete_form" phx-value-type={@form_type} type="button" class="btn-close" aria-label="Close"></button>

            <div class="form-error-tag">
                <%= error_tag @f, String.to_atom(@form_type) %>
            </div>

            <div class="clearfix"></div>
            <div class="space30"></div>
            <div class="hint">
            <span class="badge bg-dark">
                Add up to <%= @max_entries %> <%= humanize(@form_type) %>
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
            <span class="text-muted"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "یا فایل را بکشید و اینجا رها کنید.") %></span>
            <div class="clearfix"></div>
            <div class="space30"></div>

            <%= for {_ref, err} <- @errors do %>
            <div class="error">
            <%= humanize(err) %>
            </div>
            <% end %>

            <div class="row mx-auto">
            <div class="clearfix"></div>
            <div class="space10"></div>
                <%= for {entry, color} <- Enum.zip(@entries, Stream.cycle(["success", "info", "warning", "danger"])) do %>
                    <div class="entry col-sm-3 ">

                    <div class="admin-upload-img-form ">
                        <%= live_img_preview entry %>

                        <div class="clearfix"></div>
                        <div class="space10"></div>

                        <div class="progress admin-upload-form-progress">
                            <div class={"progress-bar progress-bar-striped bg-#{color}"}
                                role="progressbar"
                                style={"width: #{entry.progress}%"}
                                aria-valuenow={"#{entry.progress}%"}
                                aria-valuemin="0"
                                aria-valuemax="100">
                                <%= entry.progress %>%
                            </div>
                        </div>

                        <a href="#" phx-click="cancel-upload" phx-value-ref={entry.ref} phx-value-upload_field={@upload_field} class="col-sm-2">&times;</a>
                    </div>


                    <%= for err <- upload_errors(@upload_errors, entry) do %>
                        <div class="error">
                        <%= humanize(err) %>
                        </div>
                    <% end %>
                    </div>
                <% end %>

                <%= if @images != {} do  %>
                <%
                        {main_image, header_image} = @images
                        image = if(@form.type == "main_image", do: main_image, else: header_image)
                %>
                        <div id={"Image#{@form.type}"}>
                            <%= if !is_nil(image) and image_exist(image) do %>
                                <h3>تصاویر آپلود شده</h3>
                                <div class="clearfix"></div>
                                <div class="space20"></div>
                                <div class="admin-upload-img-form ">
                                    <a href="#" phx-click="delete_image" phx-value-type={@form.type} class="col-sm-2">&times;</a>
                                    <div class="clearfix"></div>
                                    <img src={@form.value} alt="">
                                </div>
                            <% end %>
                        </div>
                    <% end %>
            </div>
        </div>
        </div>
    """
  end

  def image_exist(image) do
    Path.join([:code.priv_dir(:mishka_html), "static", image]) |> File.exists?()
  end
end
