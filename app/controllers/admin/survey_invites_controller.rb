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
      _ctx = run SurveyInvite::Operation::Create do |ctx|
        user = ctx[:model].user
        survey = ctx[:model].survey
        flash[:notice] = "Sent Survey Invite for #{user.name} to #{survey.name}"
        return redirect_to new_admin_survey_survey_invite_url(survey_id: survey.id)
      end
    
      @survey = Survey.find(params[:survey_id])
      flash[:error] = _ctx[:flash]
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end
  end
end
