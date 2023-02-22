module Note::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :survey_id
    property :category
    property :text
    property :color
    property :coords

    validation do
      params do
        required(:id)
        required(:survey_id)
        required(:category).filled.value(:string)
        required(:text).filled.value(:string)
      end
    end
  end
end