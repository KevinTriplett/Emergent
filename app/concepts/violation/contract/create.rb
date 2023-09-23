module Violation::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :name
    property :description

    validation do
      params do
        required(:id)
        required(:name).filled.value(:string)
        required(:description).filled.value(:string)
      end
    end
  end
end