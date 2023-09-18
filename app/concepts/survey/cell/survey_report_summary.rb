class Survey::Cell::SurveyReportSummary < Cell::ViewModel
  def show
    render # renders app/cells/survey/cell/survey_report_summary/show.haml
  end

  def list
    model[:list]
  end
  def invites
    model[:invites]
  end
  def invites_hash
    model[:invites_hash]
  end
  def token
    model[:token]
  end

  def lists(state)
    hash = invites_hash[state]
    return "(none)" if hash.count == 0
    "<ul>#{hash.map {|si| "<li>#{si.user_name} #{resend_link(si)}</li>"}.join("\n")}</ul>".html_safe
  end

  def resend_link(si)
    return if si.is_created?
    cls = "resend-survey-invite-link"
    url = admin_survey_invite_patch_path(si.id)
    "<a class='#{cls}' data-id='#{si.id}' data-url='#{url}' data-token='#{token}'>resend invite</a>".html_safe
  end

  def count(state)
    invites_hash[state].count
  end

end