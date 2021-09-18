defmodule MishkaContent.Cache.ContentDraftDynamicSupervisor do

  def start_job(args) do
    DynamicSupervisor.start_child(MishkaContent.Cache.ContentDraftOtpRunner, {MishkaContent.Cache.ContentDraftManagement, args})
  end

  def running_imports(section: section) do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:"==", :"$3", section}]
    map_result = [%{id: :"$1", pid: :"$2", section: :"$3"}]
    Registry.select(MishkaContent.Cache.ContentDraftRegistry, [{match_all, guards, map_result}])
  end

  def get_draft_pid(id) do
    case Registry.lookup(MishkaContent.Cache.ContentDraftRegistry, id) do
      [] -> {:error, :get_draft_pid}
      [{pid, _type}] -> {:ok, :get_draft_pid, pid}
    end
  end
end
