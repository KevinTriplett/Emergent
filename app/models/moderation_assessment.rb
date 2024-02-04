require "openai"

class ModerationAssessment < ActiveRecord::Base
  belongs_to :user, optional: true
  has_secure_token

  STATUS = {
    created: 0,
    recorded: 10,
    assessed: 20,
    replied: 30,
    completed: 40
  }
  STATUS.each do |key, val|
    define_method("is_#{key}?") { (state || 0) == val }
    define_method("#{key}?") { (state || 0) >= val }
  end
  
  def get_state
    ModerationAssessment::STATUS.key(state)
  end

  # ----------------------------------------------------------------------
  # steps to take:
  #   get the text from MN (new spider)
  #   get AI's analysis (new spider?)
  #   post reply on MN (private message spider)

  def self.create_assessments
    all.select {|a| !a.completed?}.each do |a|
      a.run_spider("record") unless a.recorded?
      next unless a.reload.recorded?
      a.get_assessment unless a.assessed?
      next unless a.reload.assessed?
      a.run_spider("reply") unless a.replied?
      a.update_state(:completed) if a.reload.replied?
    end
  end

  # spider crawling
  def run_spider(method)
    Spider.set_message("moderation_assessment_spider", [id,method].join('|'))
    ModerationAssessmentSpider.crawl!
    until Spider.result?("moderation_assessment_spider")
      sleep 1
    end
    Spider.success?("moderation_assessment_spider")
  rescue => error
    false
  end

  # AI assessment
  def get_assessment
    submit_assistant_run
    return unless assessed?
    create_reply
  end

  def submit_assistant_run
    # get assistant, create new thread, and store original_text as thread message
    assistant_id = get_assistant_id("Modi")
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