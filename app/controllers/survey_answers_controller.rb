class SurveyAnswersController < AdminController
  layout "survey"

  def new
    run SurveyAnswer::Operation::Create::Present do |ctx|
      @form = ctx["contract.default"]
    end
  end

  def create
    _ctx = run SurveyAnswer::Operation::Create do |ctx|
      flash[:notice] = "Survey Answer was saved"
      return redirect_to new_survey_answer_url(
        position: ctx[:model].position,
        survey_invite_token: ctx[:survey_invite].token
      )
    end
  
    flash[:error] = _ctx[:flash]
    @form = _ctx["contract.default"]
    render :new, status: :unprocessable_entity
  end
  
  def edit
    run SurveyAnswer::Operation::Update::Present do |ctx|
      @form = ctx["contract.default"]
    end
  end

  def update
    _ctx = run SurveyAnswer::Operation::Update do |ctx|
      flash[:notice] = "Question updated"
      return redirect_to edit_survey_answer_url(
        position: ctx[:model].position,
        survey_invite_token: ctx[:survey_invite].token
      )
    end
  
    flash[:error] = _ctx[:flash]
    @form = _ctx["contract.default"]
    render :new, status: :unprocessable_entity
  end
end
