module Admin
  class SurveysController < AdminController
    layout "admin"
    before_action :signed_in_user

    def index
      @surveys = Survey.all
    end

    def new
      run Survey::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end
    
    def create
      _ctx = run Survey::Operation::Create do |ctx|
        flash[:notice] = "Survey #{ctx[:model].name} was created"
        return redirect_to new_admin_survey_survey_question_url(survey_id: ctx[:model].id)
      end
    
      flash[:error] = _ctx[:flash]
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def show
      # show all questions in survey
      @survey = Survey.find(params[:id])
      @survey_questions = @survey.ordered_questions
      @token = form_authenticity_token
    end

    def edit
      _ctx = run Survey::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end

    def update
      _ctx = run Survey::Operation::Update do |ctx|
        flash[:notice] = "Survey #{ctx[:model].name} updated"
        return redirect_to admin_survey_url(ctx[:model].id)
      end
    
      flash[:error] = _ctx[:flash]
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def destroy
      run Survey::Operation::Delete do |ctx|
        flash[:notice] = "Survey deleted"
        return redirect_to admin_surveys_url, status: 303
      end

      flash[:notice] = "Unable to delete Survey"
      render :index, status: :unprocessable_entity
    end
  end
end
