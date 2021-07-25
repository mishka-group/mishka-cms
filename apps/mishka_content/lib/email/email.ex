defmodule MishkaContent.Email.Email do
  import Bamboo.Email
  use Timex
  use Phoenix.HTML

  def account_email(type,info) do
    iran_now_time = Timex.now("Iran")
    new_email(
      to: "#{info.email}",
      from: "system@khatoghalam.com",
      subject: "#{info.subject}",
      headers: %{
        # "From" => "noreply@sosesh.shop",
        "Return-Path" => "#{info.email}",
        "Subject" => "#{info.subject}",
        "Date" => "#{Timex.format!(iran_now_time, "{WDshort}, {D} {Mshort} {YYYY} {h24}:{0m}:{0s} {Z}")}",
        "message-id" => "<#{:base64.encode(:crypto.strong_rand_bytes(64))}@trangell.com>"
      },
      text_body: email_type(type, info).text,
      html_body: email_type(type, info).html
    )
  end


  def email_type("forget_password", info) do
    {:safe, html} = html_sorce("forget_password", info)

    %{
      text: "کد تغییر  و فراموشی پسورد  https://khatoghalam.com/reset-password/#{info.code}",
      html: html
    }
  end

  def html_sorce(type, info) do
    raw("#{email_header(info)} #{email_main(type, info)} #{email_footer()}")
  end

  def email_main("forget_password", info) do
  end

  def email_main("reset_password", info) do
  end

  def email_main("verify_email", info) do
  end

  def email_header(_info) do
  end

  def email_footer() do
  end

end
