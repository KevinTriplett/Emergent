class AddNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes do |t|
      t.references :survey
      t.string :category
      t.string :text
      t.string :coords
      t.string :color

      t.timestamps
    end
  end
end
