module User::Operation
  class MagicLink < Trailblazer::Operation
    include SessionsHelper
    include ActionDispatch

    step :check_param
    step :get_user

    def check_param(ctx, email_or_name:, **)
      return true unless email_or_name.blank?
      ctx[:flash] = "Please enter your Mighty Networks email address or name"
      false
    end

    def get_user(ctx, email_or_name:, **)
      ucase = email_or_name.upcase
      like_clause = (Rails.env.staging? || Rails.env.staging?) ?
      "name ILIKE '#{email_or_name}' OR email ILIKE '#{email_or_name}'" :
      "UPPER(name) LIKE '#{ucase}' OR UPPER(email) LIKE '#{ucase}'"
      ctx[:user] = User.where(like_clause).first
    end
  end
end
