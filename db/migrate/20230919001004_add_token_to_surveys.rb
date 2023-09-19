class AddTokenToSurveys < ActiveRecord::Migration[7.0]
  def up
    add_column :surveys, :token, :string
    Survey.all.each {|s| s.update(token: Survey.generate_unique_secure_token)}
  end
  def down
    remove_column :surveys, :token
  end
end
