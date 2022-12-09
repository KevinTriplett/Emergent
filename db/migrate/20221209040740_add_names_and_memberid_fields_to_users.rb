class AddNamesAndMemberidFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :member_id, :integer
    add_column :users, :time_zone, :string
    add_column :users, :country, :string
  end
end
