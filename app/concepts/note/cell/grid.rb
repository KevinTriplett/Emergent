class Note::Cell::Grid < Cell::ViewModel
  def show
    render # renders app/cells/survey_invite/cell/survey_answer/show.haml
  end

  def note
    model[:note]
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
  
  def text
    note.text
  end

  def survey_group_names
    note.ordered_groups.collect(&:name)
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
end