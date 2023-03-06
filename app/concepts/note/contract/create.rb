module Note::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :survey_group_id
    property :text
    property :coords

    validation do
      params do
        required(:id)
        required(:survey_group_id).filled.value(:integer)
        required(:text).filled.value(:string)
        required(:coords)
      end
    end
  end
end