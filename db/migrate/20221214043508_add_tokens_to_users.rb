class AddTokensToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :token, :string
    add_index :users, :token, unique: true

    add_column :users, :session_token, :string
    add_index :users, :session_token, unique: true
  end
end
