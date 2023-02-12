module User::Contract
  class Update < Reform::Form
    include Dry

    property :id
    property :email
    property :name
    property :notify

    validation do
      params do
        required(:id)
        required(:email).filled.value(:string)
        required(:name).filled.value(:string)
        required(:notify)
      end
    end
  end
end