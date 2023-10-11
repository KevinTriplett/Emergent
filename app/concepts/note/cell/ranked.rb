class Note::Cell::Ranked < Cell::ViewModel
  def show
    render # renders app/cells/note/cell/survey/show.haml
  end

  def note
    model[:note]
  end
  def patch_url
    "#{model[:patch_url]}/#{note.survey_question_id}"
  end
  def token
    model[:token]
  end
  def z_index
    note.z_index
  end
  def survey_invite
    model[:invite]
  end
  def survey_answer
    survey_invite.survey_answer_for(note.survey_question_id)
  end
  def group_id
    note.survey_group_id
  end
  def question_id
    note.survey_question_id
  end
  def color
    note.group_color
  end

  def text
    note.text
  end

  def left
    (note.coords || "10px:10px").split(":")[0]
  end
  def top
    (note.coords || "10px:10px").split(":")[1]
  end

  def note_css_id
    "note-#{note.id}"
  end

  def note_dataset
    {url: patch_url, token: token, id: question_id, group_id: group_id, color: color}
  end
  def note_css_style
    "background-color: #{color}; top: #{top}; left: #{left}; z-index: #{z_index};"
  end
end