defmodule Tests do

  def is_premited?(user_roles, needed) do
    Enum.map(String.split(needed, ":"), fn x -> x in String.split(user_roles, ":") end)
    |> Enum.any?(fn x -> x == false end)
    |> case do
      true -> {:error, :is_premited?}
      false -> {:ok, :is_premited?, needed}
    end
  end


end
