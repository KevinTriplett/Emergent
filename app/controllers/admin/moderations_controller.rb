module Admin
  class ModerationsController < AdminController
    layout "admin"
    before_action :signed_in_moderator

    def index
      @moderations = Moderation.all
    end

    def new
      @token = form_authenticity_token
      @moderation = Moderation.new
    end
    
    def create
      moderation = Moderation.create(moderation_params)
      moderation.moderator = current_user
      moderation.update_state(:created, false)
      return redirect_to admin_moderations_url if moderation.save!

      render :new, status: :unprocessable_entity
    end

    def show
      @moderation = Moderation.find_by_token(params[:token])
    end

    private

    def moderation_params
      params.require(:moderation).permit! #(:url, :violation_ids)
    end

    def violations
      puts "violations = #{moderation_params[:violation_ids].select(&:present?).inspect}"
      moderation_params[:violation_ids].select(&:present?)
    end
  end
end
