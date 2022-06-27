defmodule MishkaDatabase.Schema.MishkaContent.Blog.Category do
  use Ecto.Schema
  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @all_fields ~w(
    title short_description main_image header_image description status sub alias_link meta_keywords meta_description custom_title
    robots category_visibility allow_commenting allow_liking allow_printing allow_reporting allow_social_sharing
    allow_subscription allow_bookmarking allow_notif show_hits show_time show_authors show_category show_links show_location
  )a

  schema "blog_categories" do
    field(:title, :string)
    field(:short_description, :string)
    field(:main_image, :string)
    field(:header_image, :string)
    field(:description, :string)
    field(:status, ContentStatusEnum, default: :active)
    field(:sub, :binary_id)
    field(:alias_link, :string)
    field(:meta_keywords, :string)
    field(:meta_description, :string)
    field(:custom_title, :string)
    field(:robots, ContentRobotsEnum, default: :IndexFollow)
    field(:category_visibility, CategoryVisibility, default: :show)
    field(:allow_commenting, :boolean, default: true)
    field(:allow_liking, :boolean, default: true)
    field(:allow_printing, :boolean, default: true)
    field(:allow_reporting, :boolean, default: true)
    field(:allow_social_sharing, :boolean, default: true)
    field(:allow_subscription, :boolean, default: true)
    field(:allow_bookmarking, :boolean, default: true)
    field(:allow_notif, :boolean, default: true)
    field(:show_hits, :boolean, default: true)
    field(:show_time, :boolean, default: true)
    field(:show_authors, :boolean, default: true)
    field(:show_category, :boolean, default: true)
    field(:show_links, :boolean, default: true)
    field(:show_location, :boolean, default: true)

    has_many(:blog_posts, MishkaDatabase.Schema.MishkaContent.Blog.Post, foreign_key: :category_id)

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(
    title short_description main_image description status alias_link robots category_visibility allow_commenting
    allow_liking allow_printing allow_reporting allow_social_sharing
    allow_subscription allow_bookmarking allow_notif show_hits show_time show_authors show_category show_links show_location
  )a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields,
      message:
        MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد")
    )
    |> validate_length(:title,
      max: 200,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 200
        )
    )
    |> validate_length(:short_description,
      max: 350,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 350
        )
    )
    |> validate_length(:main_image,
      max: 200,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 200
        )
    )
    |> validate_length(:header_image,
      max: 200,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 200
        )
    )
    |> validate_length(:alias_link,
      max: 200,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 200
        )
    )
    |> validate_length(:meta_keywords,
      max: 200,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 200
        )
    )
    |> validate_length(:meta_description,
      max: 164,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 164
        )
    )
    |> validate_length(:custom_title,
      max: 200,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 200
        )
    )
    |> MishkaDatabase.validate_binary_id(:sub)
    |> unique_constraint(:alias_link,
      name: :index_blog_categories_on_alias_link,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "چنین لینکی قبلا برای یک مجموعه دیگر انتخاب شده است. لطفا لینک دیگری را ارسال کنید."
        )
    )
  end
end
