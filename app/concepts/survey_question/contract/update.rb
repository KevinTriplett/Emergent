module SurveyQuestion::Contract
  class Update < Reform::Form
    include Dry

    property :id
    property :survey_id
    property :question_type
    property :question
    property :answer_type
    property :has_scale
    property :position
    property :answer_labels
    property :scale_labels
    property :scale_question

    validation do
      params do
        required(:id).filled.value(:integer)
        required(:survey_id).filled.value(:integer)
        required(:question_type).filled.value(:string)
        required(:question).filled.value(:string)
        required(:answer_type).filled.value(:string)
        required(:has_scale)
        required(:position).filled.value(:integer)
        required(:answer_labels)
        required(:scale_labels)
        required(:scale_question)
      end

      rule(:scale_question, :has_scale) do
        key.failure('must be filled') if values[:has_scale] && values[:scale_question].blank?
      end
    end
  end
end