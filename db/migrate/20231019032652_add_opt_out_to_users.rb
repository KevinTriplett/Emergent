class AddOptOutToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :opt_out, :boolean
  end
end
