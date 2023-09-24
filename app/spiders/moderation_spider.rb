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
    get_moderation_info(moderation, comment_id)
    respond(moderation, comment_id)
  end

  def get_moderation_info(moderation, comment_id)
    container = find_comment_container(comment_id)
    container.find(:css, ".comment-body").click

    author_profile_url = container.find(:css, "a.author-name")["href"]
    container.find(:css, ".comment-body").click
    sleep 1
    original_text = container.find(:css, ".comment-body").text

    member = User.find_by_profile_url(author_profile_url)
    logger.error "> COULD NOT FIND MEMBER" unless member
    return unless member

    logger.debug "> GOT AUTHOR '#{member.name}'"
    moderation.user = member
    moderation.original_text = original_text
    moderation.save!
    logger.debug "> SAVED SUCCESSFULLY"
  end

  def respond(moderation, comment_id)
    container = find_comment_container(comment_id)
    container.find(:css, ".btn-comment-reply").click
    sleep 1
    browser.send_keys(moderation.reply)
    find_reply_button(comment_id).click
  end

  # -------------------

  def find_comment_container(comment_id)
    comment_css = ".comment-item.is-highlighted[data-detail-comment='#{comment_id}'] > .comment-right"
    logger.debug "> FIND CSS # #{comment_css}"
    wait_until(comment_css)
    browser.find(:css, comment_css)
  end

  def find_reply_button(comment_id)
    reply_button_css = ".comment-item.is-highlighted[data-detail-comment='#{comment_id}'] a.submit"
    logger.debug "> FIND CSS # #{reply_button_css}"
    browser.find(:css, reply_button_css)
  end
end
