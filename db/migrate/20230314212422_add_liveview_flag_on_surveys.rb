class AddLiveviewFlagOnSurveys < ActiveRecord::Migration[7.0]
  def change
    add_column :surveys, :liveview, :boolean
  end
end
