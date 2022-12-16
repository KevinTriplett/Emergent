require 'cgi'
require 'active_support'

module SessionsHelper
  def sign_in
    params.permit(:token)
    user = User.find_by_token(params[:token])
    return unless user
    cookies.permanent.encrypted[:session_token] = user.generate_session_token
    cookies.permanent[:user_name] = user.name
  end

  def sign_out
    cookies.permanent[:session_token] = nil
    cookies.permanent[:user_name] = nil
  end

  def signed_in_user
    redirect_to(root_url, notice: "You need a magic link first") unless signed_in?
  end

  def current_user
    return unless cookies[:session_token]
    session_token = verify_and_decrypt_session_cookie(cookies[:session_token])
    @current_user ||= User.find_by_session_token(session_token)
  end

  def signed_in?
    current_user.present?
  end

  def current_user_has_role(role)
    current_user && current_user.has_role(:greeter)
  end

  def verify_and_decrypt_session_cookie(cookie, secret_key_base = Rails.application.secret_key_base)
    cookie = CGI.unescape(cookie)
    logger.info "cookie = #{cookie}"
    data, iv, auth_tag = cookie.split("--").map do |v| 
      logger.info "v = #{v}"
      Base64.strict_decode64(v)
    end
    cipher = OpenSSL::Cipher.new("aes-256-gcm")

    # Compute the encryption key
    secret = OpenSSL::PKCS5.pbkdf2_hmac(secret_key_base, "authenticated encrypted cookie", 1000, cipher.key_len, OpenSSL::Digest::SHA256.new)

    # Setup cipher for decryption and add inputs
    cipher.decrypt
    cipher.key = secret
    cipher.iv  = iv
    cipher.auth_tag = auth_tag
    cipher.auth_data = ""

    # Perform decryption
    cookie_payload = cipher.update(data)
    cookie_payload << cipher.final
    cookie_payload = JSON.parse(cookie_payload)

    # Decode Base64 encoded stored data
    decoded_stored_value = Base64.decode64(cookie_payload["_rails"]["message"])
    JSON.parse(decoded_stored_value)
  end
end