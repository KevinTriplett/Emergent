class AssociateNotesToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :notes, :survey_group_id, :integer
    remove_column :notes, :category, :string
    remove_index :notes, :survey_id
    remove_column :notes, :survey_id, :integer
    add_column :notes, :position, :integer
    add_column :survey_invites, :enable_notes, :boolean
    add_column :surveys, :live_view, :boolean
  end
end
