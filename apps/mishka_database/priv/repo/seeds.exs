alias MishkaUser.Acl.{Role, Permission, UserRole}
alias MishkaUser.User

right_user_info = %{
  "full_name" => "admin seeds",
  "username" => "admin_seeds",
  "email" => "admin-seeds@test.com",
  "password" => "AdminSeedsPassword",
  "status" => 1,
  "unconfirmed_email" => nil
}

{:ok, :add, :user, user_data} = User.create(right_user_info)


{:ok, :add, :role, data} = Role.create(%{name: "admin seeds", display_name: "admin_seeds"})
{:ok, :add, :permission, _permission_data} = Permission.create(%{role_id: data.id, value: "*"})
{:ok, :add, :user_role, _user_role_data} = UserRole.create(%{role_id: data.id, user_id: user_data.id})
