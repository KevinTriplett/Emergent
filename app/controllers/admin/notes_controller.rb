module Admin
  class NotesController < AdminController
    layout "notes"
    before_action :signed_in_user

    def index
      @survey = Survey.find(params[:survey_id])
      @patch_url = admin_note_patch_path
      @new_url = new_admin_survey_note_path(@survey.id)
      @delete_url = admin_survey_notes_path(@survey.id)
      @notes = @survey.notes
      @token = form_authenticity_token
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
      note.save ?
        (render json: { 
          model: note.reload,
          group_name: note.group_name
        }) :
        head(:bad_request)
    end

    def destroy
      run Note::Operation::Delete do |ctx|
        return render json: {}
      end
      render head(:bad_request)
    end
  end
end
