class RenameRoleColumnInUsers < ActiveRecord::Migration[7.0]
  def up
    if User.method_defined? :roles
      rename_column :users, :roles, :access_roles
    else
      add_column :users, :access_roles, :string
    end
  end

  def down
    rename_column :users, :access_roles, :roles
  end
end
