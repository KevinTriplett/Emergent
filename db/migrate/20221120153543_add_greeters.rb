class AddGreeters < ActiveRecord::Migration[7.0]
  def change
    create_table :greeters do |t|
      t.references :member
      t.string :status
      t.integer :order_permanent
      t.integer :order_temporary

      t.timestamps
    end
  end
end
