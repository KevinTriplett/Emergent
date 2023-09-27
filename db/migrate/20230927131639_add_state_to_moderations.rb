class AddStateToModerations < ActiveRecord::Migration[7.0]
  def change
    add_column :moderations, :state, :integer
    remove_column :moderations, :status, :integer
  end
end
