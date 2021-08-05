defmodule MishkaHtmlWeb.BlogPostLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Post
  alias MishkaContent.Blog.Like
  alias MishkaDatabase.Schema.MishkaContent.Comment, as: CommentSchema
  alias MishkaContent.General.{Comment, CommentLike, Bookmark}


  # TODO: sharing to social media sites
  # TODO: we need to input seo tags
  # TODO: show Options of a post on page
  # TODO: show map and implement map's SEO tag and header tag
  # TODO: create AMP page
  # TODO: create Print page
  # TODO: add subscription for user
  # TODO: show coustom title in post and header
  # TODO: show unpublish time if exists and counter
  # TODO: create reporting popup and db for administartor or editor
  # TODO: show hits and update it
  # TODO: show post links with a html box
  # TODO: show short link to share, this should be event base if exist load on db and copy on clipboard if not create
  # TODO: Create user profile picture after creating media manager

  @impl true
  def mount(%{"alias_link" => alias_link}, session, socket) do
    socket = case Post.post(alias_link, "active") do
      nil ->
        socket =
          socket
          |> put_flash(:info, "چنین محتوایی وجود ندارد")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogsLive))

        {:ok, socket}
      post ->
        if connected?(socket) do
          Post.subscribe()
          subscribe()
        end

        Process.send_after(self(), :menu, 100)

        socket =
          assign(socket,
            id: post.id,
            filters: %{},
            page: 1,
            alias_link: post.alias_link,
            page_title: "#{post.title}",
            seo_tags: seo_tags(socket, post),
            body_color: "#40485d",
            user_id: Map.get(session, "user_id"),
            post: post,
            send_comment: false,
            comment_msg: "برای ارسال نظر کلیک کنید ....",
            sub: nil,
            changeset: CommentSchema.changeset(%CommentSchema{}, %{}),
            comments: [],
            page_size: 12,
            description: nil,
            open_modal: false,
            component: nil,
            like: Like.count_post_likes(post.id, Map.get(session, "user_id")),
            sub_comment: %{},
            bookmark: !is_nil(MishkaContent.Cache.BookmarkManagement.get_record(Map.get(session, "user_id"), post.id))
          )

        {:ok, socket, temporary_assigns: [posts: [], comments: []]}
    end

    socket
  end

  @impl true
  def handle_params(%{"page" => page, "count" => _count}, _url, socket) do
    socket =
      socket
      |> assign(comments: Comment.comments(conditions: {page, socket.assigns.page_size}, filters: %{section_id: socket.assigns.id, section: "blog_post", status: "active"}, user_id: socket.assigns.user_id), page: page)
      |> push_event("jump_to_comment_form", %{})
      {:noreply, socket}
  end

  @impl true
  def handle_params(%{"page" => page}, _url, socket) do
    socket =
      socket
      |> assign(comments: Comment.comments(conditions: {page, socket.assigns.page_size}, filters: %{section_id: socket.assigns.id, section: "blog_post", status: "active"}, user_id: socket.assigns.user_id), page: page)
      |> push_event("jump_to_comment_form", %{})
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    Process.send_after(self(), {:load_comments, socket.assigns.id}, 4000)
    {:noreply, socket}
  end

  @impl true
  def handle_event("start_comment", _params, socket) do
    socket = case socket.assigns.user_id do
      nil ->
        assign(socket, comment_msg: "برای ارسال نظر باید وارد وب سایت شوید.")
      _record ->
        assign(socket, send_comment: true)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_sending_comment", _params, socket) do
    socket =
      socket
      |> assign(comment_msg: socket.assigns.comment_msg, send_comment: false, sub: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("draft", %{"_target" => ["comment", _type], "comment" => %{"description" => description}}, socket) do
    socket =
      socket
      |> assign(description: description)

    {:noreply, socket}
  end

  @impl true
  def handle_event("sub_comment", %{"sub-id" => sub_id}, socket) do
    socket = case Comment.comment(filters: %{id: sub_id, section: "blog_post", status: "active"}, user_id: socket.assigns.user_id) do
      nil ->
        socket
        |> put_flash(:warning, "به نظر می رسد نظر مذکور حذف شده باشد.")

      record ->
        socket
        |> assign(component: MishkaHtmlWeb.Client.BlogPost.SubComment, open_modal: true, sub_comment: %{
          full_name: record.user_full_name,
          description: record.description
        })
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: false, component: nil, sub_comment: %{}])}
  end

  @impl true
  def handle_event("bookmark_post", _params, socket) do
    socket = with {:user_id, false} <- {:user_id, is_nil(socket.assigns.user_id)},
         {:ok, :get_record_by_id, _error_tag, _repo_data} <- Post.show_by_id(socket.assigns.id),
         {:ok, :add, :bookmark, bookmark_info}  <- Bookmark.create(%{section: "blog_post", section_id: socket.assigns.id, user_id: socket.assigns.user_id}) do

          user_bookmark_info = %{
            extra: bookmark_info.extra,
            id: bookmark_info.id,
            section: :blog_post,
            section_id: bookmark_info.section_id,
            status: :active,
            user_id: bookmark_info.user_id
          }

          MishkaContent.Cache.BookmarkManagement.save(user_bookmark_info, socket.assigns.user_id, socket.assigns.id)

          notify_subscribers({:bookmark_post, socket.assigns.page})
          socket
    else

      {:error, :get_record_by_id, _error_tag} ->
        socket
        |> put_flash(:warning, "به نظر می رسد مطلب مذکور حذف شده است.")


      {:user_id, true} ->
        socket
        |> put_flash(:warning, "لطفا برای بوکمارک کردن این مطلب وارد وب سایت شوید")

      {:error, :add, :bookmark, _changeset} ->
        Bookmark.delete(socket.assigns.user_id, socket.assigns.id)
        MishkaContent.Cache.BookmarkManagement.delete(socket.assigns.user_id, socket.assigns.id)
        notify_subscribers({:bookmark_post, socket.assigns.page})
        socket

      _n ->
        socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("like_post", _params, socket) do
    socket = with {:user_id, false} <- {:user_id, is_nil(socket.assigns.user_id)},
          {:ok, :get_record_by_id, _error_tag, _repo_data} <- Post.show_by_id(socket.assigns.id),
          {:error, :show_by_user_and_post_id, :not_found} <- Like.show_by_user_and_post_id(socket.assigns.user_id, socket.assigns.id),
          {:ok, :add, :post_like, _like_info} <- Like.create(%{"user_id" => socket.assigns.user_id, "post_id" => socket.assigns.id}) do


            notify_subscribers({:liked_post, socket.assigns.page})
            socket
    else
      {:error, :get_record_by_id, _error_tag} ->
        socket
        |> put_flash(:warning, "به نظر می رسد مطلب مذکور حذف شده است.")

      {:ok, :show_by_user_and_post_id, liked_record} ->
        Like.delete(liked_record.id)
        notify_subscribers({:liked_post, socket.assigns.page})

        socket

      {:error, :show_by_user_and_post_id, :cast_error}  ->
          socket
          |> put_flash(:warning, "خطایی در دریافت اطلاعات وجود آماده است.")
          |> push_redirect(to: Routes.live_path(socket, __MODULE__))

      {:user_id, true} ->
        socket
        |> put_flash(:warning, "به ظاهر مشکلی وجود دارد در صورت تکرار لطفا یک بار از وب سایت خارج و دوباره وارد شوید.")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("like_comment", %{"id" => comment_id}, socket) do
    socket = with {:user_id, false} <- {:user_id, is_nil(socket.assigns.user_id)},
         {:ok, :get_record_by_id, _error_tag, _repo_data} <- Comment.show_by_id(comment_id),
         {:error, :show_by_user_and_comment_id, :not_found} <- CommentLike.show_by_user_and_comment_id(socket.assigns.user_id, comment_id),
         {:ok, :add, :comment_like, _like_info} <- CommentLike.create(%{"user_id" => socket.assigns.user_id, "comment_id" => comment_id}) do
          notify_subscribers({:liked_comment, socket.assigns.page})
          socket
    else
      {:error, :get_record_by_id, _error_tag} ->

        socket
        |> put_flash(:warning, "به نظر می رسد نظر مذکور حذف شده است.")

      {:ok, :show_by_user_and_comment_id, liked_record} ->
        CommentLike.delete(liked_record.id)
        notify_subscribers({:liked_comment, socket.assigns.page})
        socket
      _n ->
        socket
        |> put_flash(:warning, "به ظاهر مشکلی وجود دارد در صورت تکرار لطفا یک بار از وب سایت خارج و دوباره وارد شوید.")
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("reply_comment", %{"id" => id}, socket) do
    socket = with {:user_id, false} <- {:user_id, is_nil(socket.assigns.user_id)},
         {:ok, :get_record_by_id, :comment, record_info} <- Comment.show_by_id(id) do

          socket
          |> assign(sub: record_info.id, send_comment: true)
          |> push_event("jump_to_comment_form", %{description: socket.assigns.description})

    else
      {:user_id, true} ->
        socket
        |> assign(comment_msg: "برای ارسال نظر باید وارد وب سایت شوید.", send_comment: false)
        |> push_event("jump_to_comment_form", %{})

      _n ->
        socket
        |> assign(comment_msg: "چنین نظری وجود ندارد یا ممکن است حذف شده باشد.", send_comment: false)
        |> push_event("jump_to_comment_form", %{})
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("send_comment", %{"comment" => %{"description" => description}}, socket) do
    # TODO: check what comment status dose admin need?
    socket = with {:post, false} <- {:post, is_nil(Post.post(socket.assigns.alias_link, "active"))},
         {:ok, :add, :comment, _repo_data} <- Comment.create(%{description: description, sub: socket.assigns.sub, section_id: socket.assigns.id, user_id: socket.assigns.user_id}) do
          notify_subscribers({:comment, socket.assigns.page})
            socket
            |> assign(comment_msg: "نظر شما با موفقیت ارسال شد!!! برای ارسال نظر جدید کلیک کنید.", send_comment: false, sub: nil)
            |> assign(description: nil)
            |> push_event("jump_to_comment_form", %{description: nil})
    else
      {:post, true} ->
          socket
          |> put_flash(:info, "چنین محتوایی وجود ندارد یا حذف شده است.")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogsLive))

      {:error, :add, :comment, repo_error} ->
          socket
          |> assign(changeset: repo_error, sub: nil)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:load_comments, _section_id}, socket) do
    socket = update(socket, :comments, fn _comments ->
      Comment.comments(
        conditions: {socket.assigns.page, socket.assigns.page_size},
        filters: %{section_id: socket.assigns.id,
        section: "blog_post",
        status: "active"
        }, user_id: socket.assigns.user_id)
    end)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.BlogPostLive"})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:comment, page}, socket) do
    socket = if page == socket.assigns.page do
      update(socket, :comments, fn _comments ->

        Comment.comments(
          conditions: {page, socket.assigns.page_size},
          filters: %{section_id: socket.assigns.id,
          section: "blog_post",
          status: "active"
          }, user_id: socket.assigns.user_id)
      end)
    else
      socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({:bookmark_post, _page}, socket) do
    socket = case Post.post(socket.assigns.alias_link, "active") do
      nil ->
        socket
        |> put_flash(:info, "چنین محتوایی وجود ندارد یا حذف شده است.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogsLive))

      _post ->
        socket
        |> assign(bookmark: !socket.assigns.bookmark)
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({:liked_post, _page}, socket) do
    socket = case Post.post(socket.assigns.alias_link, "active") do
      nil ->
        socket
        |> put_flash(:info, "چنین محتوایی وجود ندارد یا حذف شده است.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogsLive))

      post ->
        socket
        |> assign(like: Like.count_post_likes(post.id, socket.assigns.user_id))
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({:liked_comment, page}, socket) do
    socket = if page == socket.assigns.page do
      update(socket, :comments, fn _comments ->

        Comment.comments(
          conditions: {page, socket.assigns.page_size},
          filters: %{section_id: socket.assigns.id,
          section: "blog_post",
          status: "active"
          }, user_id: socket.assigns.user_id)
      end)
    else
      socket
    end
    {:noreply, socket}
  end

  defp priority(priority) do
    case priority do
      :none -> "ندارد"
      :low -> "پایین"
      :medium -> "متوسط"
      :high -> "بالا"
      :featured -> "ویژه"
    end
  end

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "client_blog_post")
  end

  def notify_subscribers({type, user_page}) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "client_blog_post", {type, user_page})
  end

  defp seo_tags(socket, post) do
    # TODO: should change with site address
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/#{post.main_image}",
      title: "#{post.title}",
      description: if(!is_nil(post.meta_description), do: "#{post.meta_description}", else: "#{post.short_description}"),
      type: "website",
      keywords: "#{post.meta_keywords}",
      link: site_link <> Routes.live_path(socket, __MODULE__, post.alias_link)
    }
  end
end
