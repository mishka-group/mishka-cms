defmodule MishkaInstaller.Activity do
  alias MishkaDatabase.Schema.MishkaContent.Activity

  use MishkaDeveloperTools.DB.CRUD,
          module: Activity,
          error_atom: :activity,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDeveloperTools.DB.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "activity")
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec create_activity_by_start_child(map(), map()) ::
          :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def create_activity_by_start_child(params, extra \\ %{}) do
    Task.Supervisor.start_child(__MODULE__, fn ->
      convert_task_to_db(params, extra)
    end)
  end

  @spec create_activity_by_task(map(), map()) :: Task.t()
  def create_activity_by_task(params, extra \\ %{}) do
    Task.Supervisor.async_nolink(__MODULE__, fn ->
      convert_task_to_db(params, extra)
    end)
  end

  defp convert_task_to_db(params, extra) do
    create(
        %{
          type: params.type,
          section: params.section,
          section_id: params.section_id,
          priority: params.priority,
          status: params.status,
          action: params.action,
          user_id: params.user_id,
          extra: extra
        }
      )
  end

  def notify_subscribers({:ok, _, :activity, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "activity", {type_send, :ok, repo_data})
    params
  end
end
