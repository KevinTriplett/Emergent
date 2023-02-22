class Note::Cell::Grid < Cell::ViewModel
  def show
    render # renders app/cells/survey_invite/cell/survey_answer/show.haml
  end

  def note
    model[:note]
  end
  def patch_url
    model[:url]
  end
  def delete_url
    "#{model[:url]}/#{note.id}"
  end
  
  def text
    note.text
  end

  def category
    note.category
  end
  
  def coords
    note.coords.split(":")
  end

  def color
    note.color || "#FFFF99"
  end
end