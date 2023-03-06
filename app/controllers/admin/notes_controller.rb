module Admin
  class NotesController < AdminController
    layout "notes"
    before_action :signed_in_user

    def index
      @survey = Survey.find(params[:survey_id])
      @patch_url = admin_note_patch_path
      @new_url = new_admin_survey_note_path(@survey.id)
      @delete_url = admin_survey_notes_path(@survey.id)
      @survey.clean_up_notes_z_index
      @notes = @survey.ordered_notes
      @token = form_authenticity_token
      last_group = @survey.last_note_survey_group
      @template = Note.new(survey_group_id: last_group.id) if last_group
      @body_class = "admin"
    end

    def create
      _ctx = run Note::Operation::Create do |ctx|
        return render json: { 
          note: ctx[:model],
          group_name: ctx[:model].group_name
        }
      end
      render head(:bad_request)
    end

    def patch
      note = Note.find(params[:id])
      params[:model].each_pair do |attr, val|
        note.send("#{attr}=", val)
      end
      if note.save
        note.update_survey_question
        render json: { 
          model: note.reload,
          color: note.group_color,
          group_name: note.group_name,
          patch_url: admin_note_patch_path(note),
          delete_url: admin_survey_note_path(note, survey_id: note.survey)
        }
      else
        render head(:bad_request)
      end
    end

    def destroy
      run Note::Operation::Delete do |ctx|
        return render json: {}
      end
      render head(:bad_request)
    end
  end
end
