class RenameRoleColumnInUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :roles, :access_roles
  end
end
