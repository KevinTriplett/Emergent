class SwitchToRolify < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :access_roles, :string
  end
end
