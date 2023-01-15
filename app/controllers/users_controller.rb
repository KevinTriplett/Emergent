class UsersController < ApplicationController
  layout "application"
  before_action :signed_in_user

  def index
    sign_in
    @user = current_user
    return redirect_to root_path unless @user
    return render :show
  end

  def show
    sign_in
    @user = current_user
    return redirect_to root_path unless @user
  end

  def edit
    run Volunteer::Operation::Update::Present do |ctx|
      @form = ctx["contract.default"]
      render
    end
  end

  def update
    _ctx = run Volunteer::Operation::Update do |ctx|
      flash[:notice] = "User profile updated"
      return redirect_to user_url(ctx[:model].token)
    end

    @form = _ctx["contract.default"]
    render :edit, status: :unprocessable_entity
  end
end