module User::Contract
  class Update < Reform::Form
    include Dry

    property :id
    property :greeter
    property :notes
    property :status

    validation do
      params do
        required(:id)
        required(:greeter)
        required(:notes)
        required(:status)
      end
    end
  end
end
