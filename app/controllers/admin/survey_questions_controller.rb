module Admin
  class SurveyQuestionsController < AdminController
    layout "admin"
    before_action :signed_in_user

    def new
      run SurveyQuestion::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
      end
    end

    def create
      _ctx = run SurveyQuestion::Operation::Create do |ctx|
        flash[:notice] = "Survey Question was created"
        return redirect_to new_admin_survey_survey_question_url(survey_id: ctx[:model].survey_id)
      end
    
      flash[:error] = _ctx[:flash]
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def edit
      @survey = Survey.find(params[:survey_id])
      run SurveyQuestion::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
      end
    end

    def update
      @survey = Survey.find(params[:survey_id])
      _ctx = run SurveyQuestion::Operation::Update do |ctx|
        flash[:notice] = "Question updated"
        return redirect_to admin_survey_url(@survey.id)
      end
    
      flash[:error] = _ctx[:flash]
      @form = _ctx["contract.default"]
      render :edit, status: :unprocessable_entity
    end

    def patch
      _ctx = run SurveyQuestion::Operation::Patch do |ctx|
        return render json: { 
          model: ctx[:model].reload
        }
      end
      return head(:bad_request)
    end

    def destroy
      run SurveyQuestion::Operation::Delete do |ctx|
        flash[:notice] = "Question deleted"
        return redirect_to admin_survey_url, status: 303
      end

      flash[:notice] = "Unable to delete question"
      render :index, status: :unprocessable_entity
    end
  end
end
