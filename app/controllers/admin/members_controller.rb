module Admin
  class MembersController < ApplicationController
    layout "admin"

    unless Rails.env.test?
      http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
    end
  
    def index
      @members = Member.order(joined_timestamp: :desc).all
    end
  end
end