module Admin
  class SurveysController < AdminController
    layout "admin"
    before_action :signed_in_surveyor

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

    def duplicate
      _ctx = run Survey::Operation::Duplicate do |ctx|
        flash[:notice] = "Survey #{ctx[:existing_survey].name} was duplicated, showing the new survey"
        return redirect_to edit_admin_survey_url(ctx[:model].id)
      end
      
      flash[:error] = "Survey could not be duplicated, sorry about that"
      redirect_to admin_surveys_url
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
      render :edit, status: :unprocessable_entity
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
        note = ctx[:model]
        return render json: { 
          model: note,
          color: note.group_color,
          group_name: note.group_name,
          patch_url: admin_note_patch_path(note),
          delete_url: admin_survey_note_path(note, survey_id: note.survey)
        }
      end
      return head(:bad_request)
    end

    def test
      _ctx = run Survey::Operation::Test, current_user: current_user, url: survey_url do |ctx|
        return redirect_to survey_url(token: ctx[:survey_invite].token)
      end
      flash[:error] = _ctx[:flash]
      return redirect_to admin_survey_url(ctx[:model].id)
    end

    def report
      @body_id = "survey"
      @token = form_authenticity_token
      @list = params[:list]
      @survey = Survey.find(params[:id])
      @survey_questions = {}
      @survey.ordered_questions.each do |sq|
        @survey_questions[sq.survey_group] ||= []
        @survey_questions[sq.survey_group].push sq
      end  
      @survey_invites = @survey.survey_invites
      @survey_invites_hash = {
        created: [],
        sent: [],
        opened: [],
        started: [],
        finished: []
      }
      @survey_invites.each do |si|
        @survey_invites_hash[:created].push(si) if si.is_created?
        @survey_invites_hash[:sent].push(si) if si.is_invite_sent?
        @survey_invites_hash[:opened].push(si) if si.is_opened?
        @survey_invites_hash[:started].push(si) if si.is_started?
        @survey_invites_hash[:finished].push(si) if si.is_finished? || si.finished_link_sent?
      end
    end
  end
end
