class SurveysController < ApplicationController
  layout "application"
  before_action :signed_in_user

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
    _ctx = run User::Operation::Update(current_user: current_user) do |ctx|
      flash[:notice] = "User profile updated"
      return redirect_to user_url(ctx[:model].token)
    end
  
    @form = _ctx["contract.default"]
    render :edit, status: :unprocessable_entity
  end
end