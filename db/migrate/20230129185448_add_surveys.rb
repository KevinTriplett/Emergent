class AddSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :surveys do |t|
      t.string :name
      t.string :description
      t.boolean :locked # true means survey has some answers and cannot change
    end

    create_table :survey_questions do |t|
      t.references :survey
      t.integer :order
      t.string :question_type
      t.text :question
      t.string :answer_type
      t.boolean :has_scale
    end

    create_table :survey_answers do |t|
      t.references :user
      t.references :survey_question
      t.text :answer
      t.integer :scale
    end
  end
end
