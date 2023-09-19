module SurveyInvite::Contract
  class Take < Reform::Form
    include Dry

    property :survey_id
    property :user_id

    validation do
      params do
        required(:survey_id).filled.value(:integer)
        required(:user_id).filled.value(:integer)
      end
    end
  end
end