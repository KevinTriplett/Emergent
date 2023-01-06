require 'cgi'
require 'active_support'

module SessionsHelper
  class InvalidMessage < StandardError; end

  def sign_in
    params.permit(:token)
    user = User.find_by_token(params[:token])
    return unless user
    cookies.permanent.encrypted[:session_token] = user.generate_session_token
    cookies.permanent[:user_name] = user.name
    cookies.permanent[:user_id] = user.id
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
    session_token = verify_and_decrypt_cookie(:session_token)
    @current_user ||= User.find_by_session_token(session_token)
    # TODO: remove this after January 2022
    cookies.permanent[:user_name] = @current_user.name
    cookies.permanent[:user_id] = @current_user.id
    @current_user
  end

  def signed_in?
    current_user.present?
  end

  def current_user_has_role(role)
    current_user && current_user.has_role(:greeter)
  end

  # ref https://gist.github.com/wildjcrt/6359713fa770d277927051fdeb30ebbf
  def verify_and_decrypt_cookie(key, secret_key_base = Rails.application.secret_key_base, purpose = nil)
    raise "no cookie to decrypt" unless cookies[key]
    data, iv, auth_tag = cookies[key].split("--").map { |v| Base64.strict_decode64(v) }
    raise "auth_tag is invalid" if auth_tag.nil? || auth_tag.bytes.length != 16
    purpose ||= "cookie.#{key}"

    cipher = OpenSSL::Cipher.new("aes-256-gcm")

    # Compute the encryption key
    salt = Rails.configuration.action_dispatch.authenticated_encrypted_cookie_salt
    secret = OpenSSL::PKCS5.pbkdf2_hmac(secret_key_base, salt, 1000, cipher.key_len, OpenSSL::Digest::SHA256.new)

    # Setup cipher for decryption and add inputs
    cipher.decrypt
    cipher.key = secret
    cipher.iv  = iv
    cipher.auth_tag = auth_tag
    cipher.auth_data = ""

    # Perform decryption
    cookie_payload = cipher.update(data)
    cookie_payload << cipher.final
    message = ActiveSupport::Messages::Metadata.verify(cookie_payload, purpose)
    raise "cannot verify cookie" if message.nil?
    cookie_payload = JSON.parse(cookie_payload)

    # Decode Base64 encoded stored data
    decoded_stored_value = ::Base64.decode64(cookie_payload["_rails"]["message"])
    JSON.parse(decoded_stored_value)
  end
end