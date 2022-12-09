class AddSpiders < ActiveRecord::Migration[7.0]
  def change
    create_table :spiders do |t|
      t.string :name
      t.text :message
      t.string :result
    end
  end
end
