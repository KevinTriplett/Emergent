require 'emerge_spider'

class ModerationSpider < EmergeSpider
  @name = "moderation_spider"
  @engine = @@engine
  @start_urls = @@urls
  @config = @@config
  create_spider(@name)

  def parse(response, url:, data: {})
    moderation_id = get_message
    moderation = Moderation.find(moderation_id)
    sign_in_and_send_request_to(:moderate, moderation.url)
  end

  def moderate(response, url:, data: {})
    moderation_id = get_and_clear_message
    moderation = Moderation.find(moderation_id)
    logger.debug "> MODERATING #{moderation.url}"
    comment_id = url.split("/").last.split("?").first
    comment_css = ".comment-item.is-highlighted[data-detail-comment='#{comment_id}']"
    logger.debug "> FIND CSS # #{comment_css}"

    wait_until(comment_css)
    comment_li = browser.find(:css, comment_css)
    author_profile_url = comment_li.find(:css, "a.author-name")["href"]
    comment_li.find(:css, ".comment-body").click
    sleep 1
    original_text = comment_li.find(:css, ".comment-body").text

    member = User.find_by_profile_url(author_profile_url)
    logger.error "> COULD NOT FIND MEMBER" unless member
    return unless member

    logger.debug "> GOT AUTHOR '#{member.name}'"
    moderation.user = member
    moderation.original_text = original_text
    moderation.save!
    logger.debug "> SAVED SUCCESSFULLY"
  end
end
