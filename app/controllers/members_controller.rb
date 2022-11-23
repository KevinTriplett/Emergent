class MembersController < ApplicationController
  protect_from_forgery with: :null_session

  def default
    render
  end

  def index
    render
  end
end
