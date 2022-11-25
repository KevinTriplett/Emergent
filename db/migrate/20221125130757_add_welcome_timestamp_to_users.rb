class AddWelcomeTimestampToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :welcome_timestamp, :datetime
  end
end
