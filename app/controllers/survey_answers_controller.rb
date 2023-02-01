class SurveyAnswersController < AdminController
  layout "survey"

  def index
  end

  def new
  end

  def show
    # show all items in template
    get_survey_question
    @survey_questions = Survey.where(name: @survey_question.name).order(position: :asc)
  end

  def edit
    get_survey_question
  end

  def update
    get_survey_question
    _ctx = run AdminSurvey::Operation::Update do |ctx|
      flash[:notice] = "Question updated"
      return redirect_to edit_admin_survey_url(survey_id: )
    end
  
    flash[:error] = _ctx[:flash]
    @form = _ctx["contract.default"]
    render :new, status: :unprocessable_entity
  end

  def destroy
  end

  private

  def get_survey_question
    @survey_question = Survey.find(params[:id])
  end
end
