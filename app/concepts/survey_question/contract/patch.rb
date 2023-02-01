module SurveyQuestion::Contract
  class Patch < Reform::Form
    include Dry

    property :id
    property :position

    validation do
      params do
        required(:id).filled.value(:integer)
        required(:position).filled.value(:integer)
      end
    end
  end
end