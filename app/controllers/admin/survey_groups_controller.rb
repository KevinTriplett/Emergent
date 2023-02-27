module Admin
  class SurveyGroupsController < AdminController
    layout "admin"
    before_action :signed_in_user

    def new
      @return = params["return_to_notes"]
      @cancel_url = @return ? 
        admin_survey_notes_url(params[:survey_id]) :
        admin_survey_url(params[:survey_id])
      run SurveyGroup::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end
    
    def create
      _ctx = run SurveyGroup::Operation::Create do |ctx|
        flash[:notice] = "Group #{ctx[:model].name} was created"
        sg = ctx[:model]
        return redirect_to params["return_to_notes"] ? 
          admin_survey_notes_url(sg.survey_id) :
          new_admin_survey_survey_group_survey_question_url(survey_id: sg.survey_id, survey_group_id: sg.id)
      end
    
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def edit
      _ctx = run SurveyGroup::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end

    def update
      _ctx = run SurveyGroup::Operation::Update do |ctx|
        flash[:notice] = "Group #{ctx[:model].name} updated"
        return redirect_to admin_survey_url(ctx[:model].survey_id)
      end
    
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def destroy
      run SurveyGroup::Operation::Delete do |ctx|
        flash[:notice] = "Group deleted"
        return render json: { url: admin_survey_url(ctx[:model].survey_id) }
      end
      return head(:bad_request)
    end

    def patch
      _ctx = run SurveyGroup::Operation::Patch do |ctx|
        return render json: { 
          model: ctx[:model].reload
        }
      end
      return head(:bad_request)
    end
  end
end
