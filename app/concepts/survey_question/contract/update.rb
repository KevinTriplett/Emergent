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

    validation do
      params do
        required(:id).filled.value(:integer)
        required(:survey_id).filled.value(:integer)
        required(:question_type).filled.value(:string)
        required(:question).filled.value(:string)
        required(:answer_type).filled.value(:string)
        required(:has_scale)
        required(:position).filled.value(:integer)
      end
    end
  end
end