class Member < ActiveRecord::Base
  has_one :greeter
  # has_secure_token

end