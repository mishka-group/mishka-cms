defmodule MishkaDatabase.Schema.MishkaContent.Blog.Category do
  use Ecto.Schema

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @all_fields ~w(
    title short_description main_image header_image description status sub alias_link meta_keywords meta_description custom_title
    robots category_visibility allow_commenting allow_liking allow_printing allow_reporting allow_social_sharing
    allow_subscription allow_bookmarking allow_notif show_hits show_time show_authors show_category show_links show_location
  )a


  schema "blog_categories" do

    field :title, :string, size: 200, null: false
    field :short_description, :string, size: 350,null: false
    field :main_image, :string, size: 200, null: false
    field :header_image, :string, size: 200, null: true
    field :description, :string, null: false
    field :status, ContentStatusEnum, null: false, default: :active
    field :sub, :binary_id, null: true
    field :alias_link, :string, size: 200, null: false
    field :meta_keywords, :string, size: 200, null: true
    field :meta_description, :string, size: 164, null: true
    field :custom_title, :string, size: 200, null: true
    field :robots, ContentRobotsEnum, null: false, default: :IndexFollow
    field :category_visibility, CategoryVisibility, null: false, default: :show
    field :allow_commenting, :boolean, null: false, default: true
    field :allow_liking, :boolean, null: false , default: true
    field :allow_printing, :boolean, null: false , default: true
    field :allow_reporting, :boolean, null: false , default: true
    field :allow_social_sharing, :boolean, null: false , default: true
    field :allow_subscription, :boolean, null: false , default: true
    field :allow_bookmarking, :boolean, null: false , default: true
    field :allow_notif, :boolean, null: false , default: true
    field :show_hits, :boolean, null: false , default: true
    field :show_time, :boolean, null: false , default: true
    field :show_authors, :boolean, null: false , default: true
    field :show_category, :boolean, null: false , default: true
    field :show_links, :boolean, null: false , default: true
    field :show_location, :boolean, null: false , default: true

    has_many :blog_posts, MishkaDatabase.Schema.MishkaContent.Blog.Post, foreign_key: :category_id

    timestamps(type: :utc_datetime)
  end


  @required_fields ~w(
    title short_description main_image description status alias_link robots category_visibility allow_commenting
    allow_liking allow_printing allow_reporting allow_social_sharing
    allow_subscription allow_bookmarking allow_notif show_hits show_time show_authors show_category show_links show_location
  )a


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields, message: "can't be blank")
    |> validate_length(:title, max: 200, message: "maximum 200 characters")
    |> validate_length(:short_description, max: 350, message: "maximum 350 characters")
    |> validate_length(:main_image, max: 200, message: "maximum 200 characters")
    |> validate_length(:header_image, max: 200, message: "maximum 200 characters")
    |> validate_length(:alias_link, max: 200, message: "maximum 200 characters")
    |> validate_length(:meta_keywords, max: 200, message: "maximum 200 characters")
    |> validate_length(:meta_description, max: 164, message: "maximum 164 characters")
    |> validate_length(:custom_title, max: 200, message: "maximum 200 characters")
    |> unique_constraint(:alias_link, name: :index_on_blog_category_alias_link, message: "this category's alias link has already been taken.")
  end

end

# menu = [
#   %{id: 1, title: "menu 1 main", link: "#", sub: nil},
#   %{id: 2, title: "menu 2 sub menu 1", link: "#", sub: 1},
#   %{id: 3, title: "menu 3 sub menu 1", link: "#", sub: 1},
#   %{id: 4, title: "menu 4 main", link: "#", sub: nil},
#   %{id: 5, title: "menu 5 main", link: "#", sub: nil},
#   %{id: 6, title: "menu 6 sub menu 4", link: "#", sub: 4},
# ]

# Enum.reject(menu, fn x -> x.sub != nil end) |> Enum.map(fn main_menu ->
#   Map.merge(main_menu, %{subs: Enum.filter(menu, fn x -> x.sub == main_menu.id end)})
# end)
