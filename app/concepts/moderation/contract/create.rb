module Moderation::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :url
    property :moderator_id

    collection :violations do
      property :name
    end

    validation do
      params do
        required(:id)
        required(:url).filled.value(:string)
        required(:moderator_id).filled.value(:integer)
      end
    end
  end
end