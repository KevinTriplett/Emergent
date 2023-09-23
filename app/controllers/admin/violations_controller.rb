module Admin
  class ViolationsController < AdminController
    layout "admin"
    before_action :signed_in_moderator

    def index
      @token = form_authenticity_token
      @violations = Violation.all
    end

    def new
      @token = form_authenticity_token
      run Violation::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end
    
    def create
      _ctx = run Violation::Operation::Create do |ctx|
        flash[:notice] = "Violation '#{ctx[:model].name}' created"
        return redirect_to admin_violations_url
      end
    
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def show
      redirect_to edit_admin_violation_url(params[:id])
    end

    def edit
      _ctx = run Violation::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end

    def update
      _ctx = run Violation::Operation::Update do |ctx|
        flash[:notice] = "Violation '#{ctx[:model].name}' updated"
        return redirect_to admin_violations_url
      end
    
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end

    def destroy
      run Violation::Operation::Delete do |ctx|
        flash[:notice] = "Violation deleted"
        return render json: { url: admin_violations_url }
      end
      return head(:bad_request)
    end
  end
end
