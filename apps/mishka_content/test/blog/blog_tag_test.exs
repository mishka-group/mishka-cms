defmodule MishkaContentTest.Blog.BlogTagTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase

  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post

  alias MishkaContent.Blog.TagMapper
  alias MishkaContent.Blog.Tag

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  @category_info %{
    "title" => "Test Category",
    "short_description" => "Test category description",
    "main_image" => "https://test.com/png.png",
    "description" => "Test category description",
    "alias_link" => "test-category-test",
  }


  @post_info %{
    "title" => "Test Post",
    "short_description" => "Test post description",
    "main_image" => "https://test.com/png.png",
    "description" => "Test post description",
    "status" => :active,
    "priority" => :none,
    "alias_link" => "test-post-test",
    "robots" => :IndexFollow,
  }

  @tag_info %{
    title: "tag1",
    alias_link: "tag1",
    meta_keywords: "tag1",
    meta_description: "tag1",
    custom_title: "tag1",
    robots: :IndexFollow,
  }


  setup _context do
    {:ok, :add, :category, category_data} = Category.create(@category_info)
    post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
    {:ok, :add, :post, post_info} = Post.create(post_info)
    {:ok, post_info: post_info, category_info: category_data}
  end

  describe "Happy | Comment CRUD DB (▰˘◡˘▰)" do
    test "create a tag", _context do
      {:ok, :add, :blog_tag, _tag_info} = assert Tag.create(@tag_info)
    end

    test "edit a tag", _context do
      {:ok, :add, :blog_tag, tag_info} = assert Tag.create(@tag_info)
      {:ok, :edit, :blog_tag, _tag_info} = assert Tag.edit(%{id: tag_info.id, title: "tag2"})
    end

    test "delete a tag", _context do
      {:ok, :add, :blog_tag, tag_info} = assert Tag.create(@tag_info)
      {:ok, :delete, :blog_tag, _tag_info} = assert Tag.delete(tag_info.id)
    end

    test "link some tag to a post", context do

      tags = Enum.map(Enum.shuffle(1..5), fn item ->
        {:ok, :add, :blog_tag, tag} = assert Tag.create(Map.merge(@tag_info, %{
          title: "tag#{item}",
          custom_title: "tag#{item}",
          alias_link: "tag#{item}",
        }))
        tag.id
      end)
      |> Enum.map(fn id ->
        {:ok, :add, :blog_tag_mapper, tag_info} = assert TagMapper.create(%{
          post_id: context.post_info.id,
          tag_id: id
        })
        tag_info.tag_id
      end)


      post_info2 = Map.merge(@post_info, %{
        "category_id" => context.category_info.id,
        "title" => "Test Post 2",
        "alias_link" => "test-post-test2",
      })
      {:ok, :add, :post, post_info2} = Post.create(post_info2)

      {:ok, :add, :blog_tag_mapper, _tag_info} = assert TagMapper.create(%{
        post_id: post_info2.id,
        tag_id: List.first(tags)
      })

      2 = assert length(
        Tag.tag_posts(List.first(tags), condition: %{paginate: {1, 20}}).entries
        )

      5 = assert length(Tag.post_tags(context.post_info.id))
    end

  end
end
