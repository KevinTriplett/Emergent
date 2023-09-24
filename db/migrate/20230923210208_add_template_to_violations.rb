class AddTemplateToViolations < ActiveRecord::Migration[7.0]
  def change
    add_column :violations, :template, :text
    add_column :moderations, :reply, :text
  end
end
