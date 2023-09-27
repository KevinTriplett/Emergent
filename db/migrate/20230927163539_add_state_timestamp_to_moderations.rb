class AddStateTimestampToModerations < ActiveRecord::Migration[7.0]
  def change
    add_column :moderations, :state_timestamp, :datetime
  end
end
