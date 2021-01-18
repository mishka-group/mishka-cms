defmodule MishkaDatabase.CRUD do
  @moduledoc """
  ## ماکرو ساده سازی شده ایجاد - ویرایش - نمایش و خذف به کمک اکتو

  به واسطه این ماژول شما می توانید هرجایی که نیاز به ساخت کواری دارید موارد مربوط به
  کراد را به سادگی هرچه تمام تر در فایل مذکور خود پیاده سازی کنید.
  این ماژول و ماکرو های زیر مجموعه آن بیشتر برای ایجاد یک ساختار یک پارچه درست گردیدند و شما می توانید در پروژه های چتری موارد سفارشی خودتان را پیاده سازی کنید

  در مرحله اول برای استفاده از ماکرو های زیر شما باید در ماژول مربوط به خودتان اطلاعات درخواستی را بایند نمایید

  ```elixir
  use MishkaDatabase.CRUD,
                        module: YOURschemaMODULE,
                        error_atom: :your_error_tag,
                        repo: Your.Repo
  ```
  و در مرحله بعدی این ماژول را در ماژول سفارشی خود ایمپورت کنید

  ```elixir
  import MishkaDatabase.CRUD
  ```
  لازم به ذکر هست سه پارامتر زیر حتما باید ارسال گردند

  ```elixir
  module
  error_atom
  repo
  ```

  """
  defmacro __using__(opts) do
    quote(bind_quoted: [opts: opts]) do
      @interface_module opts
    end
  end



  @doc """
  ### ماکرو ساخت یک رکورد

  ## مثال
  ```elixir
  crud_add(map_of_info like: %{name: "trangell"})
  ```
  ورودی این ماکرو یک مپ می باشد و خروجی آن نیز به صورت مپ است. به صورت مثال

  ```elixir
  {:ok, :add, error_atom, data}
  {:error, :add, error_atom, changeset}
  ```

  در صورتی که می خواهید فقط پارامتر های انتخابی  از لیست پارامتر های ارسالی جدا شود و برای بانک اطلاعاتی ارسال گردد از همین ماکرو با ورودی ۲ استفاده کنید

  ###  مثال
  ```elixir
  crud_add(map_of_info like: %{name: "trangell"}, [:name])
  ```
  """
  defmacro crud_add(attrs) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      add = module_selected.__struct__
      |> module_selected.changeset(unquote(attrs))
      |> repo.insert()
      case add do
        {:ok, data}             -> {:ok, :add, error_atom, data}
        {:error, changeset}     -> {:error, :add, error_atom, changeset}
      end
    end
  end

  defmacro crud_add(attrs, allowed_fields)  do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      add = module_selected.__struct__
      |> module_selected.changeset(Map.take(unquote(attrs), unquote(allowed_fields)))
      |> repo.insert()
      case add do
        {:ok, data}             -> {:ok, :add, error_atom, data}
        {:error, changeset}     -> {:error, :add, error_atom, changeset}
      end
    end
  end



  @doc """
  ### ماکرو ویرایش یک رکورد در دیتابیس

  به کمک این ماکرو می توانید یک رکورد در بانک اطلاعاتی با آیدی آن ویرایش کنید. به همین منظور شما حتما باید آیدی رکورد درخواستی را
  به همراه مپ پارامتر های جدید ارسال نمایید. در غیر این صورت ماکرو خطا آیدی را برگشت می دهد

  ## مثال
  ```elixir
  crud_edit(map_of_info like: %{id: "6d80d5f4-781b-4fa8-9796-1821804de6ba",name: "trangell"})
  ```
  > توجه کنید آیدی ارسال حتما باید از نوع یو یو آیدی باشد.

  ورودی این ماکرو یک مپ می باشد و خروجی آن نیز به صورت مپ است. به صورت مثال

  ```elixir
  # در صورتی که درخواست شما موفقیت آمیز ذخیره شده باشد
  {:ok, :edit, error_atom, info}
  # در صورتی که آیدی شما از نوع یو یو آیدی نباشد
  {:error, :edit, error_atom, :uuid}
  # در صورتی که در ارسال داده ها خطایی روخ داده باشد
  {:error, :edit, error_atom, changeset}
  # در صورتی که رکوردی برای آیدی شما پیدا نشده باشد
  {:error, :delete, error_atom, :get_record_by_id}
  ```

  لازم به ذکر است اگر می خواهید فقط فیلد های انتخاب شده از پارامتر های ارسالی جدا گردد و به بانک اطلاعاتی ارسال شود از ماکرو با ورودی دو استفاده کنید

  ## مثال
  ```elixir
  crud_edit(map_of_info like: %{id: "6d80d5f4-781b-4fa8-9796-1821804de6ba", name: "trangell"}, [:id, :name])
  ```
  """
  defmacro crud_edit(attr) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      MishkaDatabase.CRUD.edit_record(unquote(attr), module_selected, error_atom, repo)
    end
  end

  defmacro crud_edit(attrs, allowed_fields)  do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      MishkaDatabase.CRUD.edit_record(Map.take(unquote(attrs), unquote(allowed_fields)), module_selected, error_atom, repo)
    end
  end


  @doc """
  ### ماکرو حذف یک رکورد از دیتابیس با کمک آیدی

  به کمک این ماکرو می توانید می توانید رکورد درخواستی خودتان را از دیتابیس حذف نمایید.
  برای حذف یک رکورد آیدی ارسالی باید از نوع یو یو آیدی باشد در غیر این صورت خطا دریافت خواهید کرد.

  ورودی این ماکرو یک آیدی از نوع یو یو آیدی می باشد و خروجی آن یک مپ

  ## مثال
  ```elixir
  crud_delete("6d80d5f4-781b-4fa8-9796-1821804de6ba")
  ```
  خروجی:
  باید توجه کنید این ماکرو جلوی یتیم سازی داده های وابسته به رکورد درخواستی برای حذف را می گیرد. پس در زمانی از این ماکرو استفاده کنید که داده های دیگر به داده با آیدی ارسالی
  از طرف شما وابستگی نداشته باشد.

  خروجی ها:

  ```elixir
  # در زمانی این پیام برگشت داده می شود که داده شما به صورت موفقیت آمیز حذف شده باشد
  {:ok, :delete, error_atom, struct}
  # زمانی این خطا برگشت داده می شود که شناسه ارسالی از طرف شما یو یو آیدی نباشد
  {:error, :delete, error_atom, :uuid}
  # در زمانی این خطا برگشت داده می شود که در ارسال داده ها خطایی روخ داده باشد
  {:error, :delete, error_atom, changeset}
  # در زمانی این خطا برگشت داده می شود که آیدی ارسالی در بانک اطلاعاتی وجود نداشته باشد
  {:error, :delete, error_atom, :get_record_by_id}
  # در زمانی این خطا برگشت داده می شود که رکورد دیگری وابسته به این رکورد باشد
  {:error, :delete, error_atom, :forced_to_delete}
  ```
  """
  defmacro crud_delete(id) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      MishkaDatabase.CRUD.delete_record(unquote(id), module_selected, error_atom, repo)
    end
  end


  @doc """
  ### ماکرو پیدا کردن یک رکورد در دیتابیس با کمک آیدی

  با کمک این ماکرو می توانید آیدی که از نوع یو یو آیدی می باشد  را ارسال کرده و در صورت وجود رکورد در دیتابیس آن را فراواخوانی کنید.
  خروجی این ماکرو مپ می باشد.

  # مثال
  ```elixir
  crud_get_record("6d80d5f4-781b-4fa8-9796-1821804de6ba")
  ```

  خروجی:
  ```
  {:error, error_atom, :get_record_by_id}
  {:ok, error_atom, :get_record_by_id, record_info}
  ```

  """
  defmacro crud_get_record(id) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)
      MishkaDatabase.CRUD.get_record_by_id(unquote(id), module_selected, error_atom, repo)
    end
  end


  @doc """
  ### ماکرو پیدا کردن یک رکورد در دیتابیس با کمک فیلد درخواستی

  با کمک این ماکرو می توانید یک فیلد با ولیو درخواستی خودتان در صورت وجود در دیتابیس را پیدا کنید. لازم به ذکر می باشد که اسم فیلد باید به صورت استرینگ وارد شود.


  # مثال
  ```elixir
  crud_get_by_field("email", "info@trangell.com")
  ```

  خروجی:
  ```
  {:error, error_atom, :get_record_by_field}
  {:ok, error_atom, :get_record_by_field, record_info}
  ```

  """
  defmacro crud_get_by_field(field, value) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      MishkaDatabase.CRUD.get_record_by_field(unquote(field), unquote(value), module_selected, error_atom, repo)
    end
  end





  # functions to create macro
  @doc false
  def update(changeset, attrs, module, repo) do
    module.changeset(changeset, attrs)
    |> repo.update
  end


  @doc false
  def uuid(id) do
    case Ecto.UUID.cast(id) do
      {:ok, record_id} -> {:ok, :uuid, record_id}
      _ -> {:error, :uuid}
    end
  end


  @doc false
  def get_record_by_id(id, module, error_atom, repo) do
    case repo.get(module, id) do
      nil -> {:error, error_atom, :get_record_by_id}
      record_info -> {:ok, error_atom, :get_record_by_id, record_info}
    end
  end


  @doc false
  def get_record_by_field(field, value, module, error_atom, repo) do
    case repo.get_by(module, "#{field}": value) do
      nil -> {:error, error_atom, :get_record_by_field}
      record_info -> {:ok, error_atom, :get_record_by_field, record_info}
    end
  end


  @doc false
  def edit_record(attrs, module, error_atom, repo) do
    with {:ok, :uuid, record_id} <- uuid(attrs.id),
        {:ok, error_atom, :get_record_by_id, record_info} <- get_record_by_id(record_id, module, error_atom, repo),
        {:ok, info} <- update(record_info, attrs, module, repo) do

        {:ok, :edit, error_atom, info}
      else
        {:error, :uuid} ->
          {:error, :edit, error_atom, :uuid}

        {:error, changeset} ->
          {:error, :edit, error_atom, changeset}
        _ ->
          {:error, :edit, error_atom, :get_record_by_id}
    end
  end


  @doc false
  def delete_record(id, module, error_atom, repo) do
    try do
      with {:ok, :uuid, record_id} <- uuid(id),
           {:ok, error_atom, :get_record_by_id, record_info} <- get_record_by_id(record_id, module, error_atom, repo),
           {:ok, struct} <- repo.delete(record_info) do

        {:ok, :delete, error_atom, struct}
      else
        {:error, :uuid} ->
          {:error, :delete, error_atom, :uuid}

        {:error, changeset} ->
          {:error, :delete, error_atom, changeset}

        _ ->
          {:error, :delete, error_atom, :get_record_by_id}
      end
    rescue
      _e in Ecto.ConstraintError -> {:error, :delete, error_atom, :forced_to_delete}
    end
  end


end
