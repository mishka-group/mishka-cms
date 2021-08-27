alias MishkaUser.Acl.{Role, Permission, UserRole}
alias MishkaUser.User
alias MishkaContent.Blog.{Category, Post}
alias MishkaContent.Blog.TagMapper
alias MishkaContent.Blog.Tag
alias MishkaContent.Blog.Author

if User.users(conditions: {1, 5}, filters: %{}).entries == [] do
  right_user_info = %{
    "full_name" => "کاربر مدیریت یک",
    "username" => "admin",
    "email" => "admin@admin.com",
    "password" => "AdminPassword123456",
    "status" => 1,
    "unconfirmed_email" => nil
  }

  tags = Enum.map(Enum.shuffle(1..10), fn x ->
    case Tag.create(%{
      title: "برچسب #{x}",
      alias_link: "barchasb-#{x}",
      meta_keywords: "برچسب #{x}",
      meta_description: "این برچسب در مورد برچسب #{x} هست",
      custom_title: "برچسب #{x}",
      robots: :IndexFollow,
      }) do
      {:ok, :add, :blog_tag, tag_info} -> tag_info.id

      _ -> nil
    end
  end) |> Enum.reject(fn x -> is_nil(x) end)


  sample_post =
    """
    <img class="img-fluid" src="/images/1.jpg" alt="">
    <div class="space30"></div>
    <p>لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است و برای شرایط فعلی تکنولوژی مورد نیاز و کاربردهای متنوع با هدف بهبود ابزارهای کاربردی می باشد. کتابهای زیادی در شصت و سه درصد گذشته، حال و آینده شناخت فراوان جامعه و متخصصان را می طلبد تا با نرم افزارها شناخت بیشتری را برای طراحان رایانه ای علی الخصوص طراحان خلاقی و فرهنگ پیشرو در زبان فارسی ایجاد کرد. در این صورت می توان امید داشت که تمام و دشواری موجود در ارائه راهکارها و شرایط سخت تایپ به پایان رسد وزمان مورد نیاز شامل حروفچینی دستاوردهای اصلی و جوابگوی سوالات پیوسته اهل دنیای موجود طراحی اساسا مورد استفاده قرار گیرد.</p>
    <p>لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است و برای شرایط فعلی تکنولوژی مورد نیاز و کاربردهای متنوع با هدف بهبود ابزارهای کاربردی می باشد. کتابهای زیادی در شصت و سه درصد گذشته، حال و آینده شناخت فراوان جامعه و متخصصان را می طلبد تا با نرم افزارها شناخت بیشتری را برای طراحان رایانه ای علی الخصوص طراحان خلاقی و فرهنگ پیشرو در زبان فارسی ایجاد کرد. در این صورت می توان امید داشت که تمام و دشواری موجود در ارائه راهکارها و شرایط سخت تایپ به پایان رسد وزمان مورد نیاز شامل حروفچینی دستاوردهای اصلی و جوابگوی سوالات پیوسته اهل دنیای موجود طراحی اساسا مورد استفاده قرار گیرد.</p>
    <img class="img-fluid client-home-header-post-image" src="/images/3.jpg" alt="">
    <p>لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است و برای شرایط فعلی تکنولوژی مورد نیاز و کاربردهای متنوع با هدف بهبود ابزارهای کاربردی می باشد. کتابهای زیادی در شصت و سه درصد گذشته، حال و آینده شناخت فراوان جامعه و متخصصان را می طلبد تا با نرم افزارها شناخت بیشتری را برای طراحان رایانه ای علی الخصوص طراحان خلاقی و فرهنگ پیشرو در زبان فارسی ایجاد کرد. در این صورت می توان امید داشت که تمام و دشواری موجود در ارائه راهکارها و شرایط سخت تایپ به پایان رسد وزمان مورد نیاز شامل حروفچینی دستاوردهای اصلی و جوابگوی سوالات پیوسته اهل دنیای موجود طراحی اساسا مورد استفاده قرار گیرد.</p>
    <p>لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است و برای شرایط فعلی تکنولوژی مورد نیاز و کاربردهای متنوع با هدف بهبود ابزارهای کاربردی می باشد. کتابهای زیادی در شصت و سه درصد گذشته، حال و آینده شناخت فراوان جامعه و متخصصان را می طلبد تا با نرم افزارها شناخت بیشتری را برای طراحان رایانه ای علی الخصوص طراحان خلاقی و فرهنگ پیشرو در زبان فارسی ایجاد کرد. در این صورت می توان امید داشت که تمام و دشواری موجود در ارائه راهکارها و شرایط سخت تایپ به پایان رسد وزمان مورد نیاز شامل حروفچینی دستاوردهای اصلی و جوابگوی سوالات پیوسته اهل دنیای موجود طراحی اساسا مورد استفاده قرار گیرد.</p>
    """

  categories  = [
    %{
    "title" => "جوملا",
    "short_description" => "Test category description",
    "main_image" => "/images/3.jpg",
    "description" => "این یک مجموعه برای صحبت در مورد موضوع جوملا می باشد.",
    "alias_link" => "جوملا",
    },
    %{
      "title" => "طراحی سایت",
      "short_description" => "Test category description",
      "main_image" => "/images/3.jpg",
      "description" => "این یک مجموعه برای صحبت در مورد موضوع طراحی سایت می باشد.",
      "alias_link" => "طراحی سایت",
    },
    %{
      "title" => "وردپرس",
      "short_description" => "Test category description",
      "main_image" => "/images/3.jpg",
      "description" => "این یک مجموعه برای صحبت در مورد موضوع وردپرس می باشد.",
      "alias_link" => "وردپرس",
    },
    %{
      "title" => "اخبار ترانگل",
      "short_description" => "Test category description",
      "main_image" => "/images/3.jpg",
      "description" => "این یک مجموعه برای صحبت در مورد موضوع اخبار ترانگل می باشد.",
      "alias_link" => "اخبار ترانگل",
    },
    %{
      "title" => "سئو",
      "short_description" => "Test category description",
      "main_image" => "/images/3.jpg",
      "description" => "این یک مجموعه برای صحبت در مورد موضوع سئو می باشد.",
      "alias_link" => "سئو",
    },
  ] |> Enum.map(fn cat ->
      case Category.create(cat) do
        {:ok, :add, :category, data} -> data.id
        _ -> nil
      end
  end) |> Enum.reject(fn x -> is_nil(x) end)

  posts = Enum.map(Enum.shuffle(1..60), fn x ->
    case Post.create(%{
      "title" => "موضوع مورد بحث #{x}",
      "short_description" => "طراحی سایت برای بهبود چطور می تواند برای ما باشدطراحی سایت برای بهبود چطور می تواند برای ما باشدطراحی سایت برای بهبود چطور می تواند برای ما باشد طراحی سایت برای بهبود چطور می تواند برای ما باشدطراحی سایت برای بهبود چطور می تواند برای ما باشد",
      "main_image" => "/images/#{Enum.random([1, 2, 3, 4, 5])}.jpg",
      "description" => sample_post,
      "status" => :active,
      "priority" => Enum.random([:none, :low, :medium, :high, :featured]),
      "alias_link" => "subject-#{x}",
      "robots" => :IndexFollow,
      "category_id" => Enum.random(categories)
    }) do
      {:ok, :add, :post, post_info} -> post_info.id
      _ -> nil
    end
  end) |> Enum.reject(fn x -> is_nil(x) end)


  Enum.map(posts, fn post_id ->
    Enum.map(Enum.take_random(tags, 4), fn tag_id ->
      TagMapper.create(%{
        post_id: post_id,
        tag_id: tag_id
      })
    end)
  end)



  with  {:ok, :add, :user, user_data} <- User.create(right_user_info),
        {:ok, :add, :role, data} <- Role.create(%{name: "admin seeds", display_name: "admin_seeds"}),
        {:ok, :add, :permission, _permission_data} <- Permission.create(%{role_id: data.id, value: "*"}),
        {:ok, :add, :user_role, _user_role_data} <- UserRole.create(%{role_id: data.id, user_id: user_data.id}) do

      IO.inspect("Seeds Admin User was imported: ** user_email: #{right_user_info["email"]} / user_password: #{right_user_info["password"]}")
  else
    _ ->
      IO.inspect("Seeds Admin User was imported before")
  end

  users = MishkaUser.User.users(conditions: {1, 2}, filters: %{})
  users = Enum.map(users.entries, fn user ->
    user.id
  end)

  Enum.map(posts, fn post_id ->
    Enum.map(users, fn user_id ->
      Author.create(%{"post_id" => post_id, "user_id" => user_id})
    end)
  end)

else
  IO.inspect("You loaded seeds file before")
end
