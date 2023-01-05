module User::Contract
  class Update < Reform::Form
    include Dry

    property :id
    property :greeter
    property :shadow_greeter
    property :when_timestamp
    property :notes
    property :status

    validation do
      params do
        required(:id)
        required(:greeter)
        required(:shadow_greeter)
        required(:when_timestamp)
        required(:notes)
        required(:status)
      end
    end
  end
end