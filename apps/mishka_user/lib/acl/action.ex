defmodule MishkaUser.Acl.Action do

  def actions(:content) do
    %{
      post_edit: "post:edit",
      post_delete: "post:delete"
    }
  end

  def actions(:shop) do
    %{
      product_edit: "post:edit",
      product_delete: "post:delete"
    }
  end
end
