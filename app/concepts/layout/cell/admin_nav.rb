class Layout::Cell::AdminNav < Cell::ViewModel
  def show
    render # renders app/cells/layouts/cell/admin_nav/show.haml
  end
  
  def current_user
    model[:current_user]
  end

  def first_name
    current_user.first_name
  end

  def has_role?(role)
    current_user.has_role? role
  end
end