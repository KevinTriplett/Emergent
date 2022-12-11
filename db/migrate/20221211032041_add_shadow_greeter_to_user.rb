class AddShadowGreeterToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :shadow_greeter, :string
  end
end
