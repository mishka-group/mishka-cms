defmodule MishkaHtmlWeb.AdminUserLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do

    {:ok, assign(socket, changeset: "changeset")}
  end

  def basic_menu_list() do
    [
      %{type: "full_name", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-3",
      title: "نام کامل",
      description: "ساخت نام کامل کاربر"},


      %{type: "username", status: [
        %{title: "ضروری", class: "badge bg-danger"},
        %{title: "یکتا", class: "badge bg-success"}
      ],
      form: "text",
      class: "col-sm-2",
      title: "لینک مطلب",
      description: "ساخت نام کاربری کاربر که باید در سیستم یکتا باشد و پیرو قوانین ساخت سایت باشد"},

      %{type: "email", status: [
        %{title: "ضروری", class: "badge bg-danger"},
        %{title: "یکتا", class: "badge bg-success"}
      ],
      form: "text",
      class: "col-sm-2",
      title: "ایمیل کاربر",
      description: "ایمیل کاربر پایه و اساس شناسایی کاربر در سیستم می باشد و همینطور ایمیل برای هر حساب کاربری یکتا می باشد"},

      %{type: "status", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      options: [
        {"ثب نام شده", :registered},
        {"فعال", :active},
        {"غیر فعال", :inactive},
        {"آرشیو شده", :archived},
      ],
      form: "select",
      class: "col-sm-2",
      title: "وضعیت",
      description: "وضعیت حساب کاربری"},

      %{type: "password", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "text",
      class: "col-sm-2",
      title: "پسورد",
      description: "پسورد و گذرواژه کاربر باید پیرو ساخت قوانین سیستم باشد و همینطور در بانک اطلاعاتی به صورت کد شده ذخیره سازی گردد"},

      %{type: "unconfirmed_email", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "text",
      class: "col-sm-2",
      title: "ایمیل فعال سازی",
      description: "ایمیل فعال سازی فیلدی می باشد که در صورت خالی بود یعنی حساب کاربر یک بار به وسیله ایمیل فعال سازی گردیده است. لطفا با وضعیت کاربر به صورت همزمان بررسی گردد."},
    ]
  end
end
