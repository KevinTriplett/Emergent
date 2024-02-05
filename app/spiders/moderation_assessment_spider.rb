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

  # record original text -------------------

  def record(response, url:, data: {})
    logger.info "> GETTING ORIGINAL TEXT FOR #{@@moderation.what} AT #{@@moderation.url}"

    case @@moderation.what
    when "Article", "Post"
      author_profile_url = find_post_author["href"]
      original_text = get_post_text
    when "Comment"
      author_profile_url = find_comment_author["href"]
      original_text = get_comment_text
    else
      logger.error "> UNKNOWN WHAT: #{@@moderation.what}"
    end

    @@moderation.user = User.find_by_profile_url(author_profile_url)
    @@moderation.original_text = original_text
    @@moderation.save
    @@moderation.update_state(:recorded)

    logger.error "> COULD NOT FIND MEMBER" unless @@moderation.user
    logger.info "> AUTHOR IS '#{@@moderation.user ? @@moderation.user.name : "unknown"}'"
    logger.info "> RECORDED SUCCESSFULLY"
  end

  # reply -------------------

  def reply(response, url:, data: {})
    logger.info "> REPLYING TO #{@@moderation.what} AT #{@@moderation.url}"
    
    case @@moderation.what
    when "Article", "Post"
      reply_to_post
    when "Comment"
      reply_to_comment
    else
      logger.error "> UNKNOWN WHAT: #{@@moderation.what}"
    end
    logger.info "> REPLY SUBMITTED"
  end

  # post stuff -------------------

  def get_post_text
    content = find_post_content["innerHTML"]
    title = "Article" == @@moderation.what ? find_article_title["innerHTML"] : nil
    title ? "#{title}\n\n#{content}" : content
  end
  
  def reply_to_post
    text, link = @@moderation.reply.split('|')
    logger.info "> REPLYING WITH #{text} | #{link}"

    find_post_reply_input.click
    sleep 1
    browser.send_keys(text)

    # add link
    find_post_reply_input.double_click
    find_reply_link_button.click
    browser.send_keys(link)
    find_reply_link_submit_button.click

    sleep 1
    find_post_reply_submit_button.click unless Rails.env.test?
    sleep 2

    @@moderation.update_state(:replied)
  end

  # comment stuff -------------------

  def get_comment_text
    find_comment_body.click
    sleep 1
    find_comment_body.text
  end

  def reply_to_comment
    text, link = @@moderation.reply.split('|')
    logger.info "> REPLYING WITH #{text} | #{link}"

    find_comment_reply_button.click
    # sleep 1
    # find_comment_reply_input.click
    sleep 2
    browser.send_keys(:backspace, :backspace, :backspace, :backspace, :backspace) # remove any user name link
    browser.send_keys(text)
    logger.info(">> COMMENT REPLY IS #{find_comment_reply_input.text}")

    # now add the assessment link
    find_comment_reply_input.double_click
    find_reply_link_button.click
    browser.send_keys(link)
    find_reply_link_submit_button.click

    sleep 1
    # logger.info(">> COMMENT REPLY IS #{find_comment_reply_input.text}")
    find_comment_reply_submit_button.click unless Rails.env.test?
    sleep 2

    @@moderation.update_state(:replied)
  end

  # reply link -------------------

  def find_reply_link_button
    find_css("#flyout-region #{fr_above} button[data-cmd='insertLink']", __method__)
  end

  def find_reply_link_submit_button
    find_css("#flyout-region #{fr_active} button[data-cmd='linkInsert']", __method__)
  end

  def fr_above
    sleep 1
    ".fr-toolbar#{response_has(".fr-above") ? ".fr-above" : nil}"
  end
  def fr_active
    sleep 1
    ".fr-popup#{response_has(".fr-active") ? ".fr-active" : nil}"
  end

  # post -------------------

  # post css:
  #   #flyout-region
  #      #detail-layout-attribution-region
  #         .mighty-attribution-name-container
  #             a.mighty-attribution-name <-- profile_url
  #      .detail-layout-description <-- original_text
  # article css:
  #   #flyout-region
  #     #detail-layout-attribution-region
  #       .mighty-attribution-name-container
  #         a.mighty-attribution-name <-- profile_url
  #     .detail-layout-title <-- title
  #     .detail-layout-description <-- original_text

  def find_post_author
    find_css("#flyout-region #detail-layout-attribution-region .mighty-attribution-name-container a.mighty-attribution-name", __method__)
  end

  def find_article_title
    find_css("#flyout-region .detail-layout-title", __method__)
  end

  def find_post_content
    find_css("#flyout-region .detail-layout-description", __method__)
  end

  def find_post_reply_input
    find_css("#detail-layout-comments-region .comments-form-wrapper .post-prompt-form-container p", __method__)
  end

  def find_post_reply_submit_button
    find_css("#detail-layout-comments-region .comments-form-wrapper .post-prompt-actions-container .submit-actions a.submit", __method__)
  end

  # comment -------------------
  
  # comment css:
  #   #detail-layout-comments-region
  #     .comment-item[data-detail-comment='comment_id'] <-- comment_item_css
  #       > div
  #         > a.author-name <-- profile_url
  #         .comment-show[data-detail-comment='comment_id'] <-- comment_show_css
  #           .comment-body <-- original_text
  #         > .comment-footer
  #           a.btn-comment-reply <-- reply button
  # reply css:
  #   #detail-layout-comments-region
  #     > ,comment-replies-container
  #       > .comment-reply-wrapper
  #         p <-- reply_input
  #     

  def find_comment_author
    find_css("#{comment_item_css} > div > a.author-name", __method__)
  end

  def find_comment_body
    find_css("#{comment_show_css} .comment-body", __method__)
  end

  def find_comment_reply_button
    find_css("#{comment_item_css} > div > .comment-footer a.btn-comment-reply", __method__)
  end

  # comment reply input
  #   #detail-layout-comments-region
  #     .comment-item[data-detail-comment='comment_id'] <-- comment_item_css
  #       > .comment-replies-container
  #         .comment-reply-wrapper
  #           .post-prompt-form-container
  #             p <-- reply input
  #           .post-prompt-actions-container
  #             a.submit <-- reply submit button

  def find_comment_reply_input
    find_css("#detail-layout-comments-region .comment-reply-wrapper .post-prompt-form-container p", __method__)
  end

  def find_comment_reply_submit_button
    find_css("#detail-layout-comments-region .comment-reply-wrapper a.submit", __method__)
  end

  def find_comment_last_reply
    find_css("#{comment_item_css} > .comment-replies-container .comments-list li:last-child > div .comment-body", __method__)
  end

  # utilities -------------------

  def comment_item_css
    "#detail-layout-comments-region .comment-item[data-detail-comment='#{@@comment_id}']"
  end

  def comment_show_css
    "#{comment_item_css} > div .comment-show[data-detail-comment='#{@@comment_id}']"
  end

  def find_css(css, method_name)
    logger.info "> #{method_name}: \"#{css}\""
    browser.find(:css, css)
  end
end
