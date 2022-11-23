module Member::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :name
    property :email
    property :profile_url
    property :chat_url
    property :request_timestamp
    property :join_timestamp
    property :status
    property :location
    property :questions_responses
    property :notes
    property :referral
    property :make_greeter

    validation do
      params do
        required(:id)
        required(:name).filled.value(:string)
        required(:email).filled.value(:string)
        required(:profile_url)
        required(:chat_url)
        required(:request_timestamp)
        required(:join_timestamp).filled.value(:string)
        required(:status)
        required(:location)
        required(:questions_responses)
        required(:notes)
        required(:referral)
        required(:make_greeter)
      end
  
      rule(:email) do
        key.failure('must be unique') if Member.find_by_email(values[:email])
      end
    end
  end
end
