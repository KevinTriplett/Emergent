class SurveyInvitesController < ApplicationController
  layout "application"

  def show
    @survey_invite = SurveyInvite.find_by_token(params[:token])
    @survey_invite.update(state: SurveyInvite::STATUS[:opened])
    sign_in(@survey_invite.user)
  end
end