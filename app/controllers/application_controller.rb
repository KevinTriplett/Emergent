class ApplicationController < ActionController::Base
  include SessionsHelper
  before_action :set_headers

  def set_headers
    headers["Cache-Control"] = "no-cache, no-store, must-revalidate" # HTTP 1.1.
    headers["Pragma"] = "no-cache" # HTTP 1.0.
    headers["Expires"] = "0" # Proxies.
  end
end
