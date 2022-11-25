module User::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :name
    property :email
    property :profile_url
    property :chat_url
    property :welcome_timestamp
    property :request_timestamp
    property :join_timestamp
    property :status
    property :location
    property :questions_responses
    property :notes
    property :referral
    property :greeter

    validation do
      params do
        required(:id)
        required(:name).filled.value(:string)
        required(:email).filled.value(:string)
        required(:profile_url).filled.value(:string)
        required(:chat_url)
        required(:welcome_timestamp).filled.value(:string)
        required(:request_timestamp).filled.value(:string)
        required(:join_timestamp)
        required(:status).filled.value(:string)
        required(:location)
        required(:questions_responses).filled.value(:string)
        required(:notes)
        required(:referral)
        required(:greeter)
      end
  
      rule(:email, :id) do
        email, id = values[:email], values[:id].to_i
        user = User.find_by_email(email)
        key.failure('must be unique') if !user.nil? && user.id != id
      end
    end
  end
end
