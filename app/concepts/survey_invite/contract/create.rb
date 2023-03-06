module SurveyInvite::Contract
  class Create < Reform::Form
    include Dry

    property :survey_id
    property :user_id
    property :subject
    property :body

    validation do
      params do
        required(:survey_id).filled.value(:integer)
        required(:user_id).filled.value(:integer)
        required(:subject).filled.value(:string)
        required(:body).filled.value(:string)
      end
    end
  end
end