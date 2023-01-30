module Admin
  class SurveyQuestionsController < AdminController
    layout "admin"

    def index
    end

    def new
      run SurveyQuestion::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end

    def edit
      run SurveyQuestion::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end

    def update
      _ctx = run SurveyQuestion::Operation::Update do |ctx|
        flash[:notice] = "Question updated"
        return redirect_to edit_admin_survey_url(survey_id: )
      end
    
      flash[:error] = _ctx[:flash]
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
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
