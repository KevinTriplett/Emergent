class AddApprovedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :approved, :boolean
  end
end
