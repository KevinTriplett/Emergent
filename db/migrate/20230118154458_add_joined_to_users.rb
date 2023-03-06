class AddJoinedToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :joined, :boolean
    User.all.each {|u| u.update joined: true}
  end
  def down
    remove_column :users, :joined, :boolean
  end
end
