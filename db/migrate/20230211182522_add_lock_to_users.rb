class AddLockToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :locked, :boolean
  end
end
