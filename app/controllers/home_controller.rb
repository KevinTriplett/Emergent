class HomeController < ApplicationController
  layout "home"
  def index
    @body_class = "home"
  end
end
