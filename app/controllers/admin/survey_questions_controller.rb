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
      run SurveyQuestion::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
      end
    end

    def update
      _ctx = run SurveyQuestion::Operation::Update do |ctx|
        flash[:notice] = "Question updated"
        return redirect_to admin_survey_url(params[:survey_id])
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
        return render json: { url: admin_survey_url(params[:survey_id]) }
      end
      return head(:bad_request)
    end
  end
end
