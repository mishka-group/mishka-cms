defmodule MishkaUser.Token.TokenDynamicSupervisor do

  def start_job(args) do
    DynamicSupervisor.start_child(MishkaUser.Token.TokenOtpRunner, {MishkaUser.Token.TokenSupervisor, args})
  end

  @spec running_imports :: [any]

  def running_imports() do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:"==", :"$3", "token"}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]
    Registry.select(MishkaUser.Token.TokenRegistry, [{match_all, guards, map_result}])
  end


  @spec get_user_pid(String.t()) :: {:error, :get_user_pid} | {:ok, :get_user_pid, pid}

  def get_user_pid(user_id) do
    case Registry.lookup(MishkaUser.Token.TokenRegistry, user_id) do
      [] -> {:error, :get_user_pid}
      [{pid, _type}] -> {:ok, :get_user_pid, pid}
    end
  end


end
