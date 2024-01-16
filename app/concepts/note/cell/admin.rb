class Note::Cell::Admin < Cell::ViewModel
  def show
    render # renders app/cells/note/cell/admin/show.haml
  end

  def note
    model[:note]
  end
  def group_id
    note.survey_group_id
  end
  def group_name
    note.group_name
  end
  def new_url
    model[:new_url]
  end
  def patch_url
    "#{model[:patch_url]}/#{note.id}/patch"
  end
  def delete_url
    "#{model[:delete_url]}/#{note.id}"
  end
  def token
    model[:token]
  end
  def z_index
    note.z_index
  end

  def text
    note.text
  end

  def survey_group_names
    note.ordered_note_groups.collect(&:name)
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

  def color
    note.group_color || "#FFFF99"
  end

  def note_dataset
    {url: patch_url, token: token, group_id: group_id, color: color}
  end
  def note_css_style
    "background-color: #{color}; left: #{left}; top: #{top}; z-index: #{z_index};"
  end
  
  def voting_controls
    votes = note.survey_answer.votes
    votes_left = note.survey_answer.votes_left
    "<i class='vote-up bi-hand-thumbs-up-fill'></i>\
    <i class='vote-down bi-hand-thumbs-down-fill'></i>\
    <span class='vote-count positive'>#{votes}</span>\
    (<span class='votes-left'>#{votes_left}</span> votes left)"
  end
end