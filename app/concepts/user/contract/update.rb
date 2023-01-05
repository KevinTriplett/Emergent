module User::Contract
  class Update < Reform::Form
    include Dry

    property :id
    property :greeter_id
    property :shadow_greeter_id
    property :when_timestamp
    property :notes
    property :status

    validation do
      params do
        required(:id)
        required(:greeter_id)
        required(:shadow_greeter_id)
        required(:when_timestamp)
        required(:notes)
        required(:status)
      end
    end
  end
end