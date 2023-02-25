module SurveyGroup::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :survey_id
    property :name
    property :description
    property :votes_max
    property :note_color

    validation do
      params do
        required(:id)
        required(:survey_id).filled.value(:integer)
        required(:name).filled.value(:string)
        required(:description)
        required(:votes_max)
        required(:note_color)
      end
    end
  end
end