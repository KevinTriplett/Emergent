module SurveyAnswer::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :survey_question_id
    property :survey_invite_id
    property :answer
    property :scale

    validation do
      params do
        required(:id)
        required(:survey_question_id).filled.value(:integer)
        required(:survey_invite_id).filled.value(:integer)
        required(:answer).filled.value(:string)
        required(:scale)
      end

      rule(:scale, :survey_question_id) do
        scale, survey_question_id = values[:scale], values[:survey_question_id].to_i
        survey_question = SurveyQuestion.find(survey_question_id)
        key.failure('must be an integer') if (survey_question.has_scale? && scale.blank?)
      end
    end
  end
end