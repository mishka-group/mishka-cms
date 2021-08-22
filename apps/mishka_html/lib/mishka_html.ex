defmodule MishkaHtml do

  @persian_characters ["ء" , "ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج", "چ", "ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "ک", "گ", "پ", "‍‍‍ظ", "ط", "ز", "ر", "ذ", "ژ", "د", "و", "آ", "ي", "ئ"]
  def list_tag_to_string(list, join) do
      list
      |> Enum.map(&to_string/1)
      |> Enum.join(join)
  end

  def email_sanitize(email) do
    HtmlSanitizeEx.strip_tags("#{email}")
    |> String.trim()
    |> slugify_none_nil(["_", ".", "-", "@"])
    |> String.trim()
  end

  def full_name_sanitize(full_name) do
    HtmlSanitizeEx.strip_tags("#{full_name}")
    |> slugify_none_nil(["."] ++ @persian_characters)
    |> String.replace("-", " ")
    |> String.trim()
  end

  def username_sanitize(username) do
    HtmlSanitizeEx.strip_tags("#{username}")
    |> slugify_none_nil(["_"])
    |> String.replace("-", "_")
    |> String.trim()
  end

  def title_sanitize(title) do
    HtmlSanitizeEx.strip_tags("#{title}")
    |> slugify_none_nil(["_", ".", "#", "?", "؟", "(", ")", ")", "(", "!", "!"] ++ @persian_characters)
    |> String.replace("-", " ")
    |> String.trim()
  end

  def create_alias_link(value) do
    Slug.slugify("#{value}", ignore: @persian_characters)
  end

  defp slugify_none_nil(input, allow_characters) do
    case Slug.slugify(input, ignore: allow_characters) do
      nil -> ""
      value -> value
    end
  end

  def html_form_required_fields(needed_field, []) do
    Enum.map(needed_field, fn menu -> menu.title end)
  end

  def html_form_required_fields(needed_field, user_inputs) do
    Enum.map(needed_field, fn menu ->
      if !Enum.member?(Map.keys(user_inputs), menu.type), do: menu.title
    end)
    |> Enum.filter(& !is_nil(&1))
  end

  import MishkaTranslator.Gettext

  def hello do
    gettext("Here is one string to html render")
  end
end
