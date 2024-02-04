require 'cgi'
require 'active_support'

module ModerationAssessmentHelper
  def markdown
    @renderer ||= Redcarpet::Render::HTML.new({
      hard_wrap: true,
      safe_links_only: true,
      link_attributes: {target: "_blank"}
    })
    @markdown ||= Redcarpet::Markdown.new(@renderer, {
      autolink: true,
      tables: true,
      space_after_headers: true,
      strikethrough: true,
      highlight: true,
      underline: true
    })
  end
end
