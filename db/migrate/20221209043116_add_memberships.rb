class AddMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships do |t|
      t.references :user
      t.references :space
      t.string :role
      t.datetime :start_timestamp
      t.datetime :duration_days
    end
  end
end
