class ChangeWelcomeTimestampToWhenUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :welcome_timestamp, :when_timestamp
  end
end
