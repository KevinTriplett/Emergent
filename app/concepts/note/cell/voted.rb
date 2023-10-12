class Note::Cell::Voted < Cell::ViewModel
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
  def question_id
    note.survey_question_id
  end
  def group_id
    note.survey_group_id
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
  def css_style
    "background-color: #{color};"
  end

  def voting_controls
    "<i class='vote-down bi-dash-square-fill'></i>
    <i class='vote-up bi-plus-square-fill'></i>
    <span class='vote-count'>#{stars(votes)}</span>"
  end

  def first_vote
    model[:i] == 0
  end

  def votes
    survey_answer ? survey_answer.votes : 0
  end

  def stars(num_stars)
    (0...num_stars).collect { |n| "<i class='bi-star-fill'></i>" }.join("")
  end

  def votes_left
    survey_answer ? survey_answer.votes_left : 0
  end

  def stars_remaining
    "Stars remaining: <span class='votes-remaining'>#{stars(votes_left)}</span>"
  end

  def hearts
    vote_thirds = survey_answer ? survey_answer.vote_thirds : 0
    "<span class='hearts'><i class='bi-heart#{1 == vote_thirds ? nil : " hidden"} one-third'></i>
    <i class='bi-heart-half#{2 == vote_thirds ? nil : " hidden"} two-thirds'></i>
    <i class='bi-heart-fill#{3 == vote_thirds ? nil : " hidden"} three-thirds'></i>
    <i class='bi-heart#{0 == vote_thirds ? " hide" : " hidden"} zero-thirds'></i></span>"
  end
end