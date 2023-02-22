module Admin
  class NotesController < AdminController
    layout "notes"
    before_action :signed_in_user

    def index
      @survey = Survey.find(params[:survey_id])
      @url = admin_survey_notes_url(survey_id: params[:survey_id])
      @notes = @survey.notes
      @template_note = Note.new({
        survey_id: @survey.id,
        category: @survey.last_note_category,
        text: "Click here to edit",
        coords: "0px:0px",
        color: "#FFFF99"
      })
      @token = form_authenticity_token
    end

    def create
      _ctx = run Note::Operation::Create do |ctx|
        return render json: { note: ctx[:model] }
      end
      render head(:bad_request)
    end

    def update
      note = Note.find(params[:id])
      params[:note].each_pair do |attr, val|
        note.send("#{attr}=", val)
      end
      note.save ? (render json: { note: note }) : (render head(:bad_request))
    end

    def destroy
      run Note::Operation::Delete do |ctx|
        return render json: {}
      end
      render head(:bad_request)
    end
  end
end
