defmodule MishkaContentTest.Blog.BlogLinkTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase
  alias MishkaContent.Blog.BlogLink
  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  @category_info %{
    "title" => "Test Category",
    "short_description" => "Test category description",
    "main_image" => "https://test.com/png.png",
    "description" => "Test category description",
    "alias_link" => "test-category-test"
  }

  @post_info %{
    "title" => "Test Post",
    "short_description" => "Test post description",
    "main_image" => "https://test.com/png.png",
    "description" => "Test post description",
    "status" => :active,
    "priority" => :none,
    "alias_link" => "test-post-test",
    "robots" => :IndexFollow
  }

  @blog_link %{
    "short_description" => "this is a link",
    "status" => :archived,
    "type" => :inside,
    "title" => "this is link title",
    "link" => "https://test.com/test.json",
    "short_link" => "#{Ecto.UUID.generate()}",
    "robots" => :IndexFollow
  }

  setup _context do
    {:ok, :add, :category, category_data} = Category.create(@category_info)
    post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
    {:ok, :add, :post, post_info} = Post.create(post_info)
    {:ok, post_info: post_info}
  end

  describe "Happy | BlogLink CRUD DB (▰˘◡˘▰)" do
    test "create a blog link", context do
      {:ok, :add, :blog_link, _link_info} =
        assert BlogLink.create(Map.merge(@blog_link, %{"section_id" => context.post_info.id}))
    end

    test "edit a blog link", context do
      {:ok, :add, :blog_link, link_info} =
        assert BlogLink.create(Map.merge(@blog_link, %{"section_id" => context.post_info.id}))

      {:ok, :edit, :blog_link, _link_info} =
        assert BlogLink.edit(%{id: link_info.id, robots: :NoIndexNoFollow})
    end

    test "delete a blog link", context do
      {:ok, :add, :blog_link, link_info} =
        assert BlogLink.create(Map.merge(@blog_link, %{"section_id" => context.post_info.id}))

      {:ok, :delete, :blog_link, _link_info} = assert BlogLink.delete(link_info.id)
    end

    test "links", context do
      {:ok, :add, :blog_link, link_info} =
        assert BlogLink.create(Map.merge(@blog_link, %{"section_id" => context.post_info.id}))

      1 =
        assert length(
                 BlogLink.links(
                   conditions: {1, 20},
                   filters: %{
                     section_id: link_info.section_id,
                     status: link_info.status,
                     type: link_info.type
                   }
                 ).entries
               )

      1 =
        assert length(
                 BlogLink.links(
                   filters: %{
                     section_id: link_info.section_id,
                     status: link_info.status,
                     type: link_info.type
                   }
                 )
               )
    end

    test "show by short link", context do
      {:ok, :add, :blog_link, link_info} =
        assert BlogLink.create(Map.merge(@blog_link, %{"section_id" => context.post_info.id}))

      {:ok, :get_record_by_field, :blog_link, _record_info} =
        assert BlogLink.show_by_short_link(link_info.short_link)
    end
  end

  describe "UnHappy | BlogLink CRUD DB ಠ╭╮ಠ" do
    test "links", _context do
      0 =
        assert length(
                 BlogLink.links(
                   conditions: {1, 20},
                   filters: %{section_id: Ecto.UUID.generate(), status: :active, type: :inside}
                 ).entries
               )

      0 = assert length(BlogLink.links(conditions: {1, 20}, filters: %{}).entries)
    end

    test "show by short link", _context do
      {:error, :get_record_by_field, :blog_link} =
        assert BlogLink.show_by_short_link(Ecto.UUID.generate())
    end
  end
end
