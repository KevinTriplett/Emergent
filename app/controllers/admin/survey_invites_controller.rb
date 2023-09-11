module Admin
  class SurveyInvitesController < AdminController
    layout "admin"
    before_action :signed_in_surveyor

    def new
      @survey = Survey.find(params[:survey_id])
      run SurveyInvite::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
      end
    end
    
    def create
      _ctx = run SurveyInvite::Operation::Create, url: survey_url do |ctx|
        invite = ctx[:model]
        user = invite.user.name
        survey = invite.survey.name
        invite.update url: survey_url(invite.token)
        flash[:notice] = "Sent Survey Invite for #{user} to #{survey}"
      end
    
      @survey = Survey.find(params[:survey_id])
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end
  end
end
