module Greeter::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :member_id
    property :status
    property :order_permanent
    property :order_temporary

    validation do
      params do
        required(:id)
        required(:member_id).filled.value(:integer)
        required(:status).filled.value(:string)
        required(:order_permanent).filled.value(:integer)
        required(:order_temporary).filled.value(:integer)
      end
    end
  end
end
