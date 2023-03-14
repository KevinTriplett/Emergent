module Survey::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :name
    property :description
    property :liveview

    validation do
      params do
        required(:id)
        required(:name).filled.value(:string)
        required(:description).filled.value(:string)
        required(:liveview)
      end
    end
  end
end