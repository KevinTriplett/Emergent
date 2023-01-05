class ChangeGreeterToRefUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :greeter_id, :integer
    # see below for source of hash
    {
      "Kevin"=>329,
      "Teri"=>201,
      "Sandy"=>200,
      "Mari"=>207,
      "AlekSasha"=>203,
      "John Stokdijk"=>680,
      "Kimberly"=>215
    }.each_pair do |greeter, id|
      User.where(greeter: greeter).update_all(greeter_id: id)
    end
    remove_column :users, :greeter
    # okay to lose shadow greeters
    add_column :users, :shadow_greeter_id, :integer
    remove_column :users, :shadow_greeter
  end

  def down
    add_column :users, :greeter, :string
    # see below for source of hash
    {
      "Kevin"=>329,
      "Teri"=>201,
      "Sandy"=>200,
      "Mari"=>207,
      "AlekSasha"=>203,
      "John Stokdijk"=>680,
      "Kimberly"=>215
    }.each_pair do |greeter, id|
      User.where(greeter_id: id).update_all(greeter: greeter)
    end
    remove_column :users, :greeter_id
    # okay to lose shadow greeters
    add_column :users, :shadow_greeter, :string
    remove_column :users, :shadow_greeter_id
  end
end

# irb(main):002:0> User.where("greeter <> ''").collect(&:greeter).uniq
# => ["Kevin", "Teri", "Sandy", "Mari", "AlekSasha", "John Stokdijk", "Kimberly"]
# irb(main):005:0> ["Kevin Triplett", "Teri Murphy", "Sandy Marti Poor", "mari budlong", "AlekSasha Marino", "John Stokdijk", "Kimberly Lathrop"].to_h {|g| [g, User.find_by_name(g).id]}
# => {"Kevin Triplett"=>329, "Teri Murphy"=>201, "Sandy Marti Poor"=>200, "mari budlong"=>207, "AlekSasha Marino"=>203, "John Stokdijk"=>680, "Kimberly Lathrop"=>215}
# {
#   "Kevin"=>329,
#   "Teri"=>201,
#   "Sandy"=>200,
#   "Mari"=>207,
#   "AlekSasha"=>203,
#   "John Stokdijk"=>680,
#   "Kimberly"=>215
# }
