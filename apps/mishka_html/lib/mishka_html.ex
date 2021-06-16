defmodule MishkaHtml do

  def list_tag_to_string(list, join) do
      list
      |> Enum.map(&to_string/1)
      |> Enum.join(join)
  end
end
