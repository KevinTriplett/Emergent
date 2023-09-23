class AddModerations < ActiveRecord::Migration[7.0]
  def change
    create_table :moderations do |t|
      t.string :token
      t.string :url
      t.string :original_text
      t.belongs_to :user, null: true
      t.integer :moderator_id
      t.timestamps
    end

    create_table :violations do |t|
      t.string :name
      t.string :description
    end

    create_join_table :moderations, :violations
  end
end
