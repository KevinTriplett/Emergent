class Note::Cell::Survey < Cell::ViewModel
  def show
    render # renders app/cells/note/cell/survey/show.haml
  end

  def note
    model[:note]
  end
  def group_name
    note.group_name
  end
  def patch_url
    "#{model[:patch_url]}/#{note.survey_question.id}"
  end
  def token
    model[:token]
  end
  def survey_invite
    model[:invite]
  end
  def survey_answer
    survey_invite.get_survey_answer(note.survey_question_id)
  end
  def group_position
    survey_answer.group_position
  end
  def question_id
    note.survey_question_id
  end
  
  def text
    note.text
  end

  def top
    note.coords ? note.coords.split(":")[1] : "0px"
  end
  def left
    note.coords ? note.coords.split(":")[0] : "0px"
  end

  def id
    "note-#{note.id}"
  end

  def color
    note.color || "#FFFF99"
  end

  def voting_controls
    votes = survey_answer.votes
    votes_left = survey_answer.votes_left
    "<i class='vote-up bi-hand-thumbs-up-fill'></i>\
    <i class='vote-down bi-hand-thumbs-down-fill'></i>\
    <span class='vote-count'>#{votes}</span>\
    (<span class='votes-left'>#{votes_left}</span> votes left)"
  end
end