class UsersController < ApplicationController
  layout "application"
  before_action :signed_in_greeter

  def show
    @user = current_user
  end

  def edit
    run User::Operation::Update::Present do |ctx|
      @form = ctx["contract.default"]
      render
    end
  end

  def update
    _ctx = run User::Operation::Update do |ctx|
      flash[:notice] = "User profile updated"
      return redirect_to user_url(token: ctx[:model].token)
    end
  
    flash[:error] = "Unable to update profile, please correct errors"
    @form = _ctx["contract.default"]
    render :edit, status: :unprocessable_entity
  end
end