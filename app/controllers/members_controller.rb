class MembersController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    render
  end
end
