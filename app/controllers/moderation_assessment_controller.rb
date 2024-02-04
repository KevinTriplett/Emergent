class ModerationAssessmentController < AdminController
  layout "moderation"

  def index
  end

  def show
    @moderation = ModerationAssessment.find_by_token(params[:token])
  end
end
