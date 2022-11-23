class ApplicationController < ActionController::Base
  private
  def current_member
    session[:member_token] = params[:member_token] if params[:member_token]
    Member.find_by_token( session[:member_token] )
  end
end
