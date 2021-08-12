defmodule MishkaContent.Email.EmailHelper do
  alias MishkaContent.Email.{Email, Mailer}
  # TODO: shluod be in config file or agent on ram
  # TODO: create type space for this file

  def send(type, params) do
    # TODO: we should have some config to let admin user select how to send emails when he has many request, queue or send immediately
    Task.Supervisor.async_nolink(MishkaContent.Email.EmailHelperTaskSupervisor, fn ->
      type
      |> create_email_info(params)
      |> Email.account_email()
      |> Mailer.deliver_later!()
    end)
  end


  defp create_email_info(:verify_email, {user_email, code_or_link}) do
    %{
      email: "#{user_email}",
      subject: "فعال سازی ایمیل حساب کاربری",
      description: """
      <p dir="rtl" style="text-align: right;">
      از طرف حساب کاربری شما درخواست فعال سازی ایمیل ارسال گردید است که به شرح زیر می باشد.
       در صورتی که شما ارسال کننده این پیام نبودید لطفا آن را در نظر نگیرید و در صورت تکرار لطفا با پشتیبان وب سایت در تماس باشید.
      </p>
      <p dir="rtl" style="text-align: right;">لینک یا کد فعال سازی ایمیل به شرح زیر می باشد:</p>
      <hr>
      #{code_or_link}
      <hr>
      <p> </p>
      <p dir="rtl" style="text-align: right;">
      باید به این نکته توجه داشت. در صورتی که شما از طرف وب سرویس یا اپلکیشن سایت این درخواست را کرده اید
      برای شما کد موقت و اگر از طرف سایت این درخواست را کرده باشید لینک موقت ارسال می شود در صورتی که درخواست سفارشی در موقع درخواست برای شما ثبت نشده باشد. لطفا در صورت نیاز یکی از راه های بالا را
      انتخاب کنید.
      </p>
      <p dir="rtl" style="text-align: right;">کد و لینک موقت دارای یک زمان کوتاه ۵ دقیقه ای می باشد و بعد از آن به صورت خودکار منقضی می گردد.</p>
      <p> </p>
      """,
      short_description: "درخواست فعال سازی ایمیل حساب کاربری",
      main_image_link: "https://trangell.com",
      main_image: "https://online.bobcards.com/assets/images/Loginbanner.svg"
    }
    |> Map.merge(social_info())
    |> Map.merge(site_profile_info())
  end

  defp create_email_info(:deactive_account, {user_email, code_or_link}) do
    %{
      email: "#{user_email}",
      subject: "درخواست غیر فعال سازی حساب کاربری",
      description: """
      <p dir="rtl" style="text-align: right;">
      از طرف حساب کاربری شما درخواست غیرفعال سازی حساب ارسال گردید است که به شرح زیر می باشد.
       در صورتی که شما ارسال کننده این پیام نبودید لطفا آن را در نظر نگیرید و در صورت تکرار لطفا با پشتیبان وب سایت در تماس باشید.
      </p>
      <p dir="rtl" style="text-align: right;">لینک یا کد غیرفعال سازی حساب کاربری به شرح زیر می باشد:</p>
      <hr>
      #{code_or_link}
      <hr>
      <p> </p>
      <p dir="rtl" style="text-align: right;">
      باید به این نکته توجه داشت. در صورتی که شما از طرف وب سرویس یا اپلکیشن سایت این درخواست را کرده اید
      برای شما کد موقت و اگر از طرف سایت این درخواست را کرده باشید لینک موقت ارسال می شود در صورتی که درخواست سفارشی در موقع درخواست برای شما ثبت نشده باشد. لطفا در صورت نیاز یکی از راه های بالا را
      انتخاب کنید.
      </p>
      <p dir="rtl" style="text-align: right;">کد و لینک موقت دارای یک زمان کوتاه ۵ دقیقه ای می باشد و بعد از آن به صورت خودکار منقضی می گردد.</p>
      <p> </p>
      """,
      short_description: "درخواست غیر فعال سازی حساب کاربری",
      main_image_link: "https://trangell.com",
      main_image: "https://online.bobcards.com/assets/images/Loginbanner.svg"
    }
    |> Map.merge(social_info())
    |> Map.merge(site_profile_info())
  end

  defp create_email_info(:delete_tokens, {user_email, code_or_link}) do
    %{
      email: "#{user_email}",
      subject: "درخواست پاک سازی توکن ها و سیستم های وارد شده",
      description: """
      <p dir="rtl" style="text-align: right;">
      از طرف حساب کاربری شما درخواست پاک سازی توکن ها ارسال گردید است که به شرح زیر می باشد.
       در صورتی که شما ارسال کننده این پیام نبودید لطفا آن را در نظر نگیرید و در صورت تکرار لطفا با پشتیبان وب سایت در تماس باشید.
      </p>
      <p dir="rtl" style="text-align: right;">لینک یا کد تازه پاک سازی توکن به شرح زیر می باشد:</p>
      <hr>
      #{code_or_link}
      <hr>
      <p> </p>
      <p dir="rtl" style="text-align: right;">
      باید به این نکته توجه داشت. در صورتی که شما از طرف وب سرویس یا اپلکیشن سایت این درخواست را کرده اید
      برای شما کد موقت و اگر از طرف سایت این درخواست را کرده باشید لینک موقت ارسال می شود در صورتی که درخواست سفارشی در موقع درخواست برای شما ثبت نشده باشد. لطفا در صورت نیاز یکی از راه های بالا را
      انتخاب کنید.
      </p>
      <p dir="rtl" style="text-align: right;">کد و لینک موقت دارای یک زمان کوتاه ۵ دقیقه ای می باشد و بعد از آن به صورت خودکار منقضی می گردد.</p>
      <p> </p>
      """,
      short_description: "درخواست پاک سازی توکن ها و سیستم های وارد شده",
      main_image_link: "https://trangell.com",
      main_image: "https://online.bobcards.com/assets/images/Loginbanner.svg"
    }
    |> Map.merge(social_info())
    |> Map.merge(site_profile_info())
  end


  defp create_email_info(:forget_password, {user_email, code_or_link}) do
    %{
      email: "#{user_email}",
      subject: "فراموشی پسورد",
      description: """
      <p dir="rtl" style="text-align: right;">
      از طرف حساب کاربری شما درخواست فراموشی پسورد ارسال گردید است که به شرح زیر می باشد.
       در صورتی که شما ارسال کننده این پیام نبودید لطفا آن را در نظر نگیرید و در صورت تکرار لطفا با پشتیبان وب سایت در تماس باشید.
      </p>
      <p dir="rtl" style="text-align: right;">لینک یا کد تازه سازی پسورد به شرح زیر می باشد:</p>
      <hr>
      #{code_or_link}
      <hr>
      <p> </p>
      <p dir="rtl" style="text-align: right;">
      باید به این نکته توجه داشت. در صورتی که شما از طرف وب سرویس یا اپلکیشن سایت این درخواست را کرده اید
      برای شما کد موقت و اگر از طرف سایت این درخواست را کرده باشید لینک موقت ارسال می شود در صورتی که درخواست سفارشی در موقع درخواست برای شما ثبت نشده باشد. لطفا در صورت نیاز یکی از راه های بالا را
      انتخاب کنید.
      </p>
      <p dir="rtl" style="text-align: right;">کد و لینک موقت دارای یک زمان کوتاه ۵ دقیقه ای می باشد و بعد از آن به صورت خودکار منقضی می گردد.</p>
      <p> </p>
      """,
      short_description: "درخواست فراموشی پسورد",
      main_image_link: "https://trangell.com",
      main_image: "https://online.bobcards.com/assets/images/Loginbanner.svg"
    }
    |> Map.merge(social_info())
    |> Map.merge(site_profile_info())
  end

  defp social_info() do
    %{
      twitter_link: "https://trangell.com",
      twitter_icon: "https://cdn.recast.ai/newsletter/twitter.png",
      facebook_link: "https://trangell.com",
      facebook_icon: "https://cdn.recast.ai/newsletter/facebook.png",
      youtube_link: "https://trangell.com",
      youtube_icon: "https://cdn.recast.ai/newsletter/youtube.png",
    }
  end

  defp site_profile_info() do
    %{
      profile_link: "https://trangell.com",
      profile_image: "https://media-exp1.licdn.com/dms/image/C5603AQFtRFL55RuHJQ/profile-displayphoto-shrink_800_800/0/1624988937475?e=1634169600&v=beta&t=1SehaRFvsduufeURo8xT3wIjDw3s_5fzerOm0-06ZG0",
      profile_name: "Shahryar",
      profile_job_link: "https://trangell.com",
      profile_job_title: "Elixir Developer",
      profile_job_short_description: "Computer programmer at Trangell",
      site_link: "https://trangell.com",
      site_email_logo: "https://trangell.com/images/smal-trangell-logo-354df0f2f90aa2b0d28da7916c607781.png?vsn=d",
    }
  end

  def email_site_link_creator(site_url, router) do
    """
      <p style="color:#BDBDBD; line-height: 30px">
        <a href="#{site_url <> router}" style="color: #3498DB;">
          #{site_url <> router}
        </a>
      </p>
      <hr>
      <p style="color:#BDBDBD; line-height: 30px">
        copy: #{site_url <> router}
      </p>
    """
  end
end
