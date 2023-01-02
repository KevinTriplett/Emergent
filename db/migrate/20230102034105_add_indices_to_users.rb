class AddIndicesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :email
    add_index :users, :status
  end
end
