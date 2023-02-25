module Admin
  class SurveysController < AdminController
    layout "admin"
    before_action :signed_in_user

    def index
      @surveys = Survey.all
      @token = form_authenticity_token
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
        return redirect_to new_admin_survey_survey_group_url(survey_id: ctx[:model].id)
      end
    
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def show
      # show all questions in survey
      @survey = Survey.find(params[:id])
      @survey_groups = @survey.ordered_groups
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
    
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def destroy
      run Survey::Operation::Delete do |ctx|
        flash[:notice] = "Survey deleted"
        return render json: { url: admin_surveys_url }
      end
      return head(:bad_request)
    end

    def new_note
      survey = Survey.find(params[:id])
      group = survey.last_note_survey_group
      # make like it came from a form:
      params[:survey_group_id] = group.id
      params.delete(:id)
      params[:note] = params
      run Note::Operation::Create, survey_group_id: group.id do |ctx|
        return render json: { 
          model: ctx[:model],
          group_name: group.name,
          first_note_url: admin_survey_notes_path(survey.id)
        }
      end
      return head(:bad_request)
    end

    def test
      url = survey_url
      _ctx = run Survey::Operation::Test, current_user: current_user, url: url do |ctx|
        survey_invite = ctx[:survey_invite]
        return redirect_to survey_url(token: survey_invite.token)
      end
      flash[:error] = _ctx[:flash]
      return redirect_to admin_survey_url(ctx[:model].id)
    end
  end
end
