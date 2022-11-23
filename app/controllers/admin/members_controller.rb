module Admin
  class MembersController < ApplicationController
    layout "admin"

    unless Rails.env.test?
      http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
    end
  
    def index
      @members = Member.order(joined_timestamp: :desc).all
    end

    def new
      run Member::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end

    def create
      _ctx = run Member::Operation::Create do |ctx|
        flash[:error] = "#{ctx[:model].name} was created"
        return redirect_to new_admin_member_url
      end
    
      flash[:error] = _ctx[:flash]
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end
  
    def edit
      run Member::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end
  
    def update
      _ctx = run Member::Operation::Update do |ctx|
        flash[:notice] = "#{ctx[:model].name} was updated"
        return redirect_to admin_members_url
      end
    
      @form = _ctx["contract.default"] # FIXME: redundant to #create!
      render :edit, status: :unprocessable_entity
    end

    def destroy
      run Member::Operation::Delete do |ctx|
        flash[:notice] = "Game deleted"
        return redirect_to admin_members_url, status: 303
      end

      flash[:notice] = "Unable to delete Game"
      render :index, status: :unprocessable_entity
    end

  end
end