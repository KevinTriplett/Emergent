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
    sign_in_and_send_request_to(:moderator, :moderate, moderation.url)
  end

  def moderate(response, url:, data: {})
    moderation_id = get_and_clear_message
    moderation = Moderation.find(moderation_id)
    logger.info "> MODERATING #{moderation.url}"

    comment_id = /\/comments\/(\d+)/.match(moderation.url)
    comment_id = comment_id[1] if comment_id

    record(moderation, comment_id) unless moderation.recorded?
    moderation.reload
    reply(moderation, comment_id) unless moderation.replied?
  end

  def record(moderation, comment_id)
    comment_id.nil? ? 
      record_post_info(moderation) : 
      record_comment_info(moderation, comment_id)
    moderation.update_state(:recorded)
    logger.info "> AUTHOR IS '#{moderation.user_name}'"
    logger.info "> RECORDED SUCCESSFULLY"
  end
  
  def reply(moderation, comment_id)
    comment_id.nil? ? 
      reply_to_post(moderation) : 
      reply_to_comment(moderation, comment_id)
    moderation.update_state(:replied)
    logger.info "> REPLY SUBMITTED"
  end

  # -------------------
  
  def record_post_info(moderation)
    container = find_post_container
    author_profile_url = container.find(:css, ".profile-attribution-link-container a.mighty-attribution-name")["href"]
    original_text = container.find(:css, ".detail-layout-description")['innerHTML']

    member = User.find_by_profile_url(author_profile_url)
    logger.error "> COULD NOT FIND MEMBER" unless member
    return unless member

    moderation.user = member
    moderation.original_text = original_text
    moderation.save!
  end

  def reply_to_post(moderation)
    find_post_reply_input.click
    sleep 1
    browser.send_keys(moderation.reply)
    find_post_reply_submit_button.click
  end

  # -------------------

  def record_comment_info(moderation, comment_id)
    container = find_comment_container(comment_id)
    container.find(:css, ".comment-body").click

    author_profile_url = container.find(:css, "a.author-name")["href"]
    container.find(:css, ".comment-body").click
    sleep 1
    original_text = container.find(:css, ".comment-body").text

    member = User.find_by_profile_url(author_profile_url)
    logger.error "> COULD NOT FIND MEMBER" unless member
    return unless member

    moderation.user = member
    moderation.original_text = original_text
    moderation.save!
  end

  def reply_to_comment(moderation, comment_id)
    find_comment_reply_input(comment_id).click
    sleep 1
    browser.send_keys(moderation.reply)
    find_comment_reply_submit_button(comment_id).click
  end

  # -------------------

  def find_post_container
    comment_css = ".detail-layout-content-wrapper"
    logger.debug "> FIND CSS # #{comment_css}"
    wait_until(comment_css)
    browser.find(:css, comment_css)
  end

  def find_post_reply_input
    input_css = "#detail-layout-comments-region .comments-form-wrapper .universal-input-wysiwyg-region p"
    logger.debug "> FIND CSS # #{input_css}"
    wait_until(input_css)
    browser.find(:css, input_css)
  end

  def find_post_reply_submit_button
    submit_button_css = "#detail-layout-comments-region .comments-form-wrapper .universal-input .post-prompt-actions-container a.submit"
    logger.debug "> FIND CSS # #{submit_button_css}"
    browser.find(:css, submit_button_css)
  end

  def find_comment_container(comment_id)
    comment_css = ".comment-item.is-highlighted[data-detail-comment='#{comment_id}'] > .comment-right"
    logger.debug "> FIND CSS # #{comment_css}"
    wait_until(comment_css)
    browser.find(:css, comment_css)
  end

  def find_comment_reply_input(comment_id)
    container = find_comment_container(comment_id)
    container.find(:css, ".btn-comment-reply")
  end

  def find_comment_reply_submit_button(comment_id)
    submit_button_css = ".comment-item.is-highlighted[data-detail-comment='#{comment_id}'] a.submit"
    logger.debug "> FIND CSS # #{submit_button_css}"
    browser.find(:css, submit_button_css)
  end
end
