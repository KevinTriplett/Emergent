module Admin
  class SurveyInvitesController < AdminController
    layout "admin"
    before_action :signed_in_user

    def new
      @survey = Survey.find(params[:survey_id])
      run SurveyInvite::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end
    
    def create
      _ctx = run SurveyInvite::Operation::Create, url: survey_url do |ctx|
        user = ctx[:model].user.name
        survey = ctx[:model].survey.name
        flash[:notice] = "Sent Survey Invite for #{user} to #{survey}"
      end
    
      @survey = Survey.find(params[:survey_id])
      flash[:error] = _ctx[:flash] unless _ctx[:flash].blank?
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end
  end
end
