module Admin
  class GreetersController < ApplicationController
    layout "admin"

    unless Rails.env.test?
      http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
    end
  
    def index
      @greeters = Greeter.order(joined_timestamp: :desc).all
    end

    def destroy
      run Greeter::Operation::Delete do |ctx|
        flash[:notice] = "Greeter removed"
        return redirect_to admin_greeters_url, status: 303
      end

      flash[:notice] = "Unable to remove Greeter"
      render :index, status: :unprocessable_entity
    end

  end
end