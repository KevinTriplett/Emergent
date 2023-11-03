require "jotform/jotform"

module Admin
  class JotformController < AdminController
    layout "admin"
    before_action :signed_in_greeter

    def show
      jotform = JotForm.new("1616349777c9deee58563c24c2f35c1c")
      @forms = []
      @subs = []
      case params[:cmd]
      when "get-forms"
        @type_name = "Forms"
        @forms = jotform.getForms()
      when "get-subs"
        @type_name = "Submissions"
        @subs = jotform.getFormSubmissions(params[:form_id])
      when "get-sub"
        @type_name = "Submission"
        @sub = jotform.getSubmission(params[:sub_id])
      end
    end
  end
end
