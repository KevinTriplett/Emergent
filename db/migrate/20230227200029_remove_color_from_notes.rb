class RemoveColorFromNotes < ActiveRecord::Migration[7.0]
  def change
    remove_column :notes, :color, :string
  end
end
