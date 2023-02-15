module SurveyQuestion::Contract
  class Create < Reform::Form
    include Dry

    property :survey_id
    property :question_type
    property :question
    property :answer_type
    property :has_scale
    property :answer_labels
    property :scale_labels
    property :scale_question

    validation do
      params do
        required(:survey_id).filled.value(:integer)
        required(:question_type).filled.value(:string)
        required(:question)
        required(:answer_type).filled.value(:string)
        required(:has_scale)
        required(:answer_labels)
        required(:scale_labels)
        required(:scale_question)
      end

      rule(:question, :question_type) do
        key.failure('must be filled') unless values[:question_type] == "New Page" || values[:question]
      end
      rule(:scale_question, :has_scale) do
        key.failure('must be filled') unless values[:has_scale] == 0 || values[:scale_question]
      end
    end
  end
end