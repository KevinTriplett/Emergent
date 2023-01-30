module Survey::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :name
    property :description

    validation do
      params do
        required(:id)
        required(:name).filled.value(:string)
        required(:description)
      end

      rule(:name, :id) do
        name, id = values[:name], values[:id].to_i
        survey = Survey.find_by_name(name)
        key.failure('must be unique') if !survey.nil? && survey.id != id
      end
    end
  end
end