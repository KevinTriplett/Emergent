module Admin
  class ModerationsController < AdminController
    layout "admin"
    before_action :signed_in_moderator

    def index
      @moderations = map_moderations_for_index_view(Moderation.all)
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

    def resolved
      @moderation = Moderation.find_by_token(params[:token])
      @moderation.update_state(:resolved) ?
        flash[:notice] = "Marked as resolved" :
        flash[:error] = "Could not mark resolved"
      render :show
    end

    private

    def moderation_params
      params.require(:moderation).permit! #(:url, :violation_ids)
    end

    def violations
      puts "violations = #{moderation_params[:violation_ids].select(&:present?).inspect}"
      moderation_params[:violation_ids].select(&:present?)
    end

    def map_moderations_for_index_view(moderations)
      moderations.map do |m|
        {
          "url": admin_moderation_path(token: m.token),
          "name": m.user_name,
          "moderator": m.moderator_name,
          "state": m.get_state,
          "violations": m.violations.map(&:name).join(", "),
          "created": m.created_at.picker_date,
          "link": m.url,
          "css_class": m.get_state
        }
      end
    end
  end
end
