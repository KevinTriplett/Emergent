class AddNotificationsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :notifications, :boolean
  end
end
