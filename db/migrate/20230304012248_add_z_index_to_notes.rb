class AddZIndexToNotes < ActiveRecord::Migration[7.0]
  def change
    add_column :notes, :z_index, :integer
  end
end
