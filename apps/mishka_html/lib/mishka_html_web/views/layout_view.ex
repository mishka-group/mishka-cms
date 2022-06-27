defmodule MishkaHtmlWeb.LayoutView do
  use MishkaHtmlWeb, :view

  # SEO tags function should have all required fields
  def seo_tags(
        %{
          image: _image,
          title: _title,
          description: _description,
          type: _type,
          keywords: _keywords,
          link: _link
        } = tags
      ) do
    raw("#{seo_tags_converter(tags, :basic_tag)} #{seo_tags_converter(tags, :social_tag)} ")
  end

  def seo_tags(_seo_tag), do: ""

  defp seo_tags_converter(seo_tags, :basic_tag) do
    """
      \n
      \t <meta name="description" content="#{seo_tags.description}" /> \n
      \t <meta name="keywords" content="#{seo_tags.keywords}" />  \n
      \t <base href="#{seo_tags.link}" /> \n
      \t <link href="#{seo_tags.link}" rel="canonical" /> \n
    """
  end

  defp seo_tags_converter(seo_tags, :social_tag) do
    """
      \n
      \t <meta property="og:image" content="#{seo_tags.image}" /> \n
      \t <meta property="og:image:width" content="482" /> \n
      \t <meta property="og:image:height" content="451" /> \n
      \t <meta property="og:title" content="#{seo_tags.title}" /> \n
      \t <meta property="og:description" content="#{seo_tags.description}" /> \n
      \t <meta property="og:type" content="#{seo_tags.type}" /> \n
      \t <meta property="og:url" content="#{seo_tags.link}" /> \n
      \n
      \t <meta name="twitter:image" content="#{seo_tags.image}" /> \n
      \t <meta name="twitter:card" content="summary_large_image" />  \n
      \t <meta name="twitter:url" content="#{seo_tags.link}" /> \n
      \t <meta name="twitter:title" content="#{seo_tags.title}" /> \n
      \t <meta name="twitter:description" content="#{seo_tags.description}" /> \n
    """
  end
end
