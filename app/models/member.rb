class Member < ActiveRecord::Base
  has_one :greeter, dependent: :destroy
  # has_secure_token

  attr_accessor :make_greeter
end