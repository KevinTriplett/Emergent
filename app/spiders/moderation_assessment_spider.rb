require 'emerge_spider'

class ModerationAssessmentSpider < EmergeSpider
  @name = "moderation_assessment_spider"
  @engine = @@engine
  @start_urls = @@urls
  @config = @@config
  create_spider(@name)

  def parse(response, url:, data: {})
    id, method = get_message.split("|")
    @@moderation = ModerationAssessment.find id
    # https://mightynetworks.com/app/8/spaces/4747401/posts/48965144
    # https://mightynetworks.com/app/8/spaces/4747401/posts/48965144/comments/3768493
    @@comment_id = /\/comments\/(\d+)/.match(@@moderation.url)
    @@comment_id = @@comment_id[1] if @@comment_id

    sign_in_and_send_request_to(:moderation, method.to_sym, @@moderation.url)
  end

  def record(response, url:, data: {})
    logger.info "> GETTING ORIGINAL TEXT FOR #{@@moderation.url}"
    @@comment_id.nil? ? record_post : record_comment
    logger.info "> AUTHOR IS '#{@@moderation.user ? @@moderation.user.name : "unknown"}'"
    logger.info "> RECORDED SUCCESSFULLY"
  end

  def reply(response, url:, data: {})
    @@comment_id.nil? ? reply_to_post : reply_to_comment
    logger.info "> REPLY SUBMITTED"
  end

  # post -------------------
  
  def record_post
    author_profile_url = find_post_author["href"]
    member = User.find_by_profile_url(author_profile_url)
    logger.error "> COULD NOT FIND MEMBER" unless member

    original_text = find_post_content["innerHTML"]

    @@moderation.user = member
    @@moderation.original_text = original_text
    @@moderation.save
    @@moderation.update_state(:recorded)
  end

  def reply_to_post
    text, link = @@moderation.reply.split('|')
    logger.info "> REPLYING TO POST #{@@moderation.url}"
    find_post_reply_input.click
    sleep 1
    browser.send_keys(text)

    find_post_reply_input.double_click
    find_reply_link_button.click
    browser.send_keys(link)
    find_reply_link_submit_button.click

    find_post_reply_submit_button.click unless Rails.env.test?
    @@moderation.update_state(:replied)
  end

  # comment -------------------

  # https://emergent-commons.mn.co/posts/hastily-thought/comments/100781250
  def record_comment
    container = find_comment_container
    author_profile_url = container.find(:css, "a.author-name")["href"]
    member = User.find_by_profile_url(author_profile_url)
    logger.error "> COULD NOT FIND MEMBER" unless member

    container.find(:css, ".comment-body").click
    sleep 1
    original_text = container.find(:css, ".comment-body").text

    @@moderation.user = member if member
    @@moderation.original_text = original_text
    @@moderation.save
    @@moderation.update_state(:recorded)
  end

  def reply_to_comment
    text, link = @@moderation.reply.split('|')
    logger.info "> REPLYING TO COMMENT #{@@moderation.url}"
    find_comment_reply_button.click
    sleep 1
    # remove the user name link
    browser.send_keys(:delete, :delete, :delete, :delete, :delete)
    browser.send_keys(text)

    find_comment_reply_input.double_click
    find_reply_link_button.click
    browser.send_keys(link)
    find_reply_link_submit_button.click

    find_comment_reply_submit_button.click unless Rails.env.test?
    @@moderation.update_state(:replied)
  end

  # reply link -------------------

  def find_reply_link_button
    find_css(".flyout-left .fr-toolbar.fr-above button[data-cmd='insertLink']", __method__)
  end

  def find_reply_link_submit_button
    find_css(".flyout-left .fr-popup.fr-active button[data-cmd='linkInsert']", __method__)
  end

  # post -------------------

  def find_post_content
    find_css("#post-detail-layout .detail-layout-description", __method__)
  end

  def find_post_author
    find_css("#detail-layout-user-info-region .person-info-container .person-name a", __method__)
  end

  def find_post_reply_input
    find_css("#detail-layout-comments-region .comments-form-wrapper .universal-input-form-body-container .fr-element.fr-view p", __method__)
  end

  def find_post_reply_submit_button
    find_css("#detail-layout-comments-region .comments-form-wrapper .universal-input .post-prompt-actions-container a.submit", __method__)
  end

  # comment -------------------

  def find_comment_reply_button
    find_css("a.btn-comment-reply", __method__, find_comment_container)
  end

  def find_comment_reply_input
    find_css(".comment-replies-container p", __method__, find_comment_container)
  end

  def find_comment_reply_submit_button
    find_css(".submit-actions a.submit", __method__, find_comment_container)
  end

  # utilities -------------------

  def find_comment_container
    find_css(".flyout-left .comments-list .comment-item[data-detail-comment='#{@@comment_id}']", __method__)
  end

  def find_css(css, method_name, dom=nil)
    logger.debug "> #{method_name}: \"#{css}\""
    wait_until(css)
    (dom || browser).find(:css, css)
  end
end
