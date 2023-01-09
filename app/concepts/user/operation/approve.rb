module User::Operation
  class Approve < Trailblazer::Operation

    step Model(User, :find_by)
    step :activate_spider
    step :update_model

    def activate_spider(ctx, model:, **)
      data = [model.first_name,model.last_name].join('|')
      Spider.set_message("approve_user_spider", data)
      ApproveUserSpider.crawl!
      until result = Spider.get_result("approve_user_spider")
        sleep 1
      end
      return false if result.to_i == 0
      ctx[:model].member_id = result.to_i
    end

    def update_model(ctx, model:, admin:, **)
      model.status= "Joined!"
      model.greeter_id = admin.id
      model.profile_url = "https://emergent-commons.mn.co/members/#{model.member_id}"
      model.chat_url = "https://emergent-commons.mn.co/chats/new?user_id=#{model.member_id}"
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S UTC")
      model.change_log = "#{model.change_log}#{timestamp} Join request approved by #{admin.name}\n"
      model.save
    end
  end
end
