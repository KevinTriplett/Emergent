require "openai"

# From https://github.com/alexrudall/anthropic/pull/10/commits/7c4eaa0fe5cfb3e0771b9cafb301e3208e9cde24
# module Anthropic
#   class Client
#     def messages(model:, messages:, system: nil, max_attempts: 5, retry_seconds: 1, parameters: {}) # rubocop:disable Metrics/MethodLength
#       parameters.merge!(system: system) if system
#       parameters.merge!(model: model, messages: messages)

#       # TODO: does this level of retry implementation belong here?
#       attempts = max_attempts
#       while 0 <= attempts -= 1
#         Anthropic::Client.json_post(path: "/messages", parameters: parameters).tap do |response|
#           # handle successful response
#           return response if response.dig("content", 0, "text")

#           # handle error response
#           error_type = response.dig("error", "type")
#           error_message = response.dig("error", "message")
#           if %w[overloaded_error api_error rate_limit_error].include?(error_type) # rubocop:disable Style/GuardClause
#             # retry loop with exponential backoff
#             sleep(retry_seconds * attempts)
#           else
#             raise Anthropic::Error, error_message
#           end
#         end
#       end
#       raise Anthropic::Error, "Failed after #{max_attempts} attempts. #{error_message}"
#     end
#   end
# end

class ModerationAssessment < ActiveRecord::Base
  belongs_to :user, optional: true
  has_secure_token

  STATUS = {
    created: 0,
    recorded: 10,
    assessed: 20,
    violation: 25,
    replied: 30,
    alerted: 35,
    completed: 40
  }
  STATUS.each do |key, val|
    define_singleton_method("#{key}_key") { val }
    define_method("is_#{key}?") { (state || 0) == val }
    define_method("#{key}?") { (state || 0) >= val }
  end
  
  def get_state
    ModerationAssessment::STATUS.key(state)
  end

  # ----------------------------------------------------------------------
  # steps to take:
  #   get the text from MN (new spider)
  #   get AI's analysis (new spider)
  #   send alert to all moderators on redline violation detected

  def self.create_assessments
    where.not(state: completed_key).each do |a|
      puts "got #{a.id} with state = #{a.get_state}"
      a.record_text unless a.recorded?
      next unless a.reload.recorded?
      a.get_assessment unless a.assessed?
      next unless a.reload.assessed?
      a.check_for_violation unless a.violation?
    end
  end

  def self.send_alerts
    where(state: violation_key).each do |assessment|
      User.with_role(:moderator).each do |mod|
        assessment.update_state(:completed) if assessment.send_violation_alert(mod.id)
      end
    end
  end

  def send_violation_alert(mod_id)
    Spider.set_message("private_message_spider", [mod_id,assessment,url].join('|'))
    PrivateMessageSpider.crawl!
    until Spider.result?("private_message_spider")
      sleep 1
    end
    Spider.success?("private_message_spider")
  rescue => error
    false
  end

  def record_text
    update_state(:recorded) if run_assessment_spider("record")
  end

  # spider crawling
  def run_assessment_spider(method)
    Spider.set_message("moderation_assessment_spider", [id,method].join('|'))
    ModerationAssessmentSpider.crawl!
    until Spider.result?("moderation_assessment_spider")
      sleep 1
    end
    Spider.success?("moderation_assessment_spider")
  rescue => error
    false
  end

  def get_assessment
    # submit_anthropic_assistant_run
    submit_open_ai_assistant_run
  end

  def check_for_violation
    return unless assessment.start_with?('Violation') || assessment == '0'
    update_state('0' == assessment ? :completed : :violation)
  end

  def get_open_ai_assessment
    submit_open_ai_assistant_run
    return unless reload.assessed?
    create_reply
  end

system_prompt = 'You moderate an online forum and when you detect one of the below violations 
within the provided text, respond with either "violation" with the violation or "0": 
- threat of violence, 
- name calling, 
- personal or group attack, 
- ad hominem, 
- doxxing, 
- any kind of commercial offer.'.squish

  def submit_anthropic_assistant_run
    client = Anthropic::Client.new
    response = client.messages(
      model: "claude-3-opus-20240229",
      system: system_prompt,
      messages: [{user: original_text}],
      parameters: {
        max_tokens_to_sample: 1000
      }
    )
    self.assessment = response
    save
  rescue
  end

  def submit_open_ai_assistant_run
    # get assistant, create new thread, and store original_text as thread message
    assistant_id = get_assistant_id("Violet")
    client = OpenAI::Client.new
    client.assistants.retrieve(id: assistant_id)
    response = client.threads.create
    self.thread_id = response["id"]
    self.message_id = client.messages.create(
      thread_id: thread_id,
      parameters: {
        role: "user", # Required for manually created messages
        content: original_text
      }
    )["id"]

    # create a run on the thread
    self.run_id = client.runs.create(thread_id: thread_id,
      parameters: {
          assistant_id: assistant_id
      }
    )["id"]
    save

    # wait until an assessment returns
    for i in 0..30
      response = client.runs.retrieve(id: run_id, thread_id: thread_id)
      status = response['status']
      case status
      when 'queued', 'in_progress', 'cancelling'
        puts 'Sleeping'
        sleep 1 # Wait one second and poll again
      when 'completed'
        break # Exit loop and report result to user
      when 'requires_action'
        puts "Unexpected status response: #{status}"
        return
      when 'cancelled', 'failed', 'expired'
        puts response['last_error'].inspect
        return
      else
        puts "Unknown status response: #{status}"
        return
      end
    end

    # get and store assessment
    messages = client.messages.list(thread_id: thread_id)
    self.assessment = messages["data"].first["content"].first["text"]["value"]
    puts "got assessment: #{assessment}"

    # clean up thread (had an error one time trying to delete the thread)
    sleep 1
    client.threads.delete(id: thread_id)
    self.message_id = nil
    self.thread_id = nil
    self.run_id = nil
    save

    # update state if successful with assessment
    update_state(:assessed) if assessment.present?
  end

  def get_assistant_id(name)
    case name
    when "Modi"
      "asst_SitO4FFxVnjmJMZv7TWxvd37"
    when "Violet"
      "asst_8ZVzdX2yAqXnDLm6gtGbx1C5"
    end
  end

  def create_reply
    update(reply: "assessment|https://emergentcommons.app/m/#{token}")
  end

  def update_state(key)
    update(state: STATUS[key]) if STATUS[key]
  end
end

# example Claude assessment:
# Here is my analysis of the rhetorical devices and scoring:

# Logical Fallacies: None clearly identified

# Respectful Tone: 9/10

#     Thoughtfully explores tension between harmony and debate
#     Empathetic to differing perspectives and communication needs
#     Allows for passionate disagreement within community

# Logical Coherence: 8/10

#     Extended metaphor aptly applies abstract principles
#     Reasonable clarity in explaining risks, benefits and alternatives
#     Could be sharpened with direct speech examples

# This piece provides a considered model for how to foster productive disagreement and clarify beliefs while sustaining fellowship. It makes the logically sound and ethically responsible argument that open debate brings depth, while enforced conformity breeds shallowness. Amidst inevitable conflict, the tone remains gracious, nuanced and solution-focused.