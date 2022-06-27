defmodule MishkaContent.Cache.BookmarkDynamicSupervisor do
  @spec start_job(list() | map() | tuple() | String.t()) ::
          :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_job(args) do
    DynamicSupervisor.start_child(
      MishkaContent.Cache.BookmarkOtpRunner,
      {MishkaContent.Cache.BookmarkManagement, args}
    )
  end

  @spec running_imports :: [any]

  def running_imports() do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:==, :"$3", "user_bookmarks"}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]
    Registry.select(MishkaContent.Cache.BookmarkRegistry, [{match_all, guards, map_result}])
  end

  @spec get_user_pid(String.t()) :: {:error, :get_user_pid} | {:ok, :get_user_pid, pid}

  def get_user_pid(user_id) do
    case Registry.lookup(MishkaContent.Cache.BookmarkRegistry, user_id) do
      [] -> {:error, :get_user_pid}
      [{pid, _type}] -> {:ok, :get_user_pid, pid}
    end
  end
end
