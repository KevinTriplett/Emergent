module User::Operation
  class Approve < Trailblazer::Operation

    step Model(User, :find_by)
    step :activate_spider
    step :update_user
    step Contract::Persist()

    def activate_spider(ctx, model:, **)
      data = {
        email: model.email,
        first_name: model.first_name,
        last_name: model.last_name
      }
      Spider.set_message("approve_user_spider", Marshal.dump(data))
      ApproveUserSpider.crawl!
      until result = Spider.get_result("approve_user_spider")
        sleep 1
      end
      ctx[:model].member_id = result.to_i
    end

    def update_user(ctx, model:, admin:, **)
      model.status= "Joined!"
      model.greeter_id = admin.id
      model.profile_url = "https://emergent-commons.mn.co/members/#{model.member_id}"
      model.chat_url = "https://emergent-commons.mn.co/chats/new?user_id=#{model.member_id}"
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      model.change_log += "#{timestamp} Approved by #{admin.name}\n"
    end
  end
end
