class RenameRoleColumnInUsers < ActiveRecord::Migration[7.0]
  def change
    if User.method_defined? :roles
      rename_column :users, :roles, :access_roles
    else
      add_column :users, :access_roles, :string
    end
  end
end
