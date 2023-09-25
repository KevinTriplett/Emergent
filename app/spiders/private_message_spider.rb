require 'emerge_spider'

class PrivateMessageSpider < EmergeSpider
  @name = "private_message_spider"
  @engine = @@engine
  @start_urls = @@urls
  @config = @@config
  create_spider(@name)

  def parse(response, url:, data: {})
    @@lines = get_and_clear_message.split("|")
    @@user = User.find @@lines.shift # first element in array is user_id
    sign_in_and_send_request_to(:surveyor, :send_message, @@user.chat_url)
  end

  def send_message(response, url:, data: {})
    logger.info "> SENDING MESSAGE TO #{@@user.name} FOR #{@@lines.first}"
    wait_until(".universal-input.chat-prompt .fr-element.fr-view")
    logger.debug "> ATTEMPTING TO CLICK CHAT CHANNEL"
    browser.find(:css, ".universal-input.chat-prompt .fr-element.fr-view").click
    logger.debug "> ATTEMPTING TO SEND #{@@lines}"

    @@lines.each do |line|
      next if line.blank?
      browser.send_keys(line)
      browser.send_keys [:enter]
      browser.send_keys [:enter]
      sleep 2
    end
  end
end
