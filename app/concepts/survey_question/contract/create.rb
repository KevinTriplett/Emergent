module SurveyQuestion::Contract
  class Create < Reform::Form
    include Dry

    property :survey_id
    property :question_type
    property :question
    property :answer_type
    property :has_scale

    validation do
      params do
        required(:survey_id).filled.value(:integer)
        required(:question_type).filled.value(:string)
        required(:question).filled.value(:string)
        required(:answer_type).filled.value(:string)
        required(:has_scale)
      end
    end
  end
end