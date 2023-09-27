class AddStatusToModerations < ActiveRecord::Migration[7.0]
  def change
    add_column :moderations, :status, :integer
  end
end
