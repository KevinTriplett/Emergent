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
    "#{model[:patch_url]}/#{note.id}/patch"
  end
  def token
    model[:token]
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

  def color
    note.color || "#FFFF99"
  end

  def voting_controls
    votes = note.survey_answer.votes
    votes_left = note.survey_answer.votes_left
    "<i class='vote-up bi-hand-thumbs-up-fill'></i>\
    <i class='vote-down bi-hand-thumbs-down-fill'></i>\
    <span class='vote-count'>#{votes}</span>\
    (<span class='votes-left'>#{votes_left}</span> votes left)"
  end
end