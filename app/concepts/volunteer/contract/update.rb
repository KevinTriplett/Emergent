module Volunteer::Contract
  class Update < Reform::Form
    include Dry

    property :id
    property :email
    property :notifications

    validation do
      params do
        required(:id)
        required(:email)
        required(:notifications)
      end
    end
  end
end