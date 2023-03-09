############################
# user-specific test helpers

NAMES = %w(john jane eric lee harvey sam kevin hank)
SURNAMES = %w(smith jones doe windsor johnson klaxine)
PROVIDERS = %w(gmail domain example sample yahoo gargole)
TLDS = %w(com it org club pl ru uk aus)
def random_email
  begin
    @_last_random_email = "#{ NAMES.sample }.#{ SURNAMES.sample }@#{ PROVIDERS.sample }.#{ TLDS.sample }"
  end while User.find_by_email(last_random_email)
  @_last_random_email
end

def last_random_email
  @_last_random_email
end

def random_user_name
  @_last_random_user_name = "#{ NAMES.sample } #{ SURNAMES.sample }"
end

def last_random_user_name
  @_last_random_user_name
end

def mock_qna
  "1q\\1a -:- 2q\\2a -:- 3q\\3a -:- 4q\\4a -:- 5q\\5a"
end

def set_authorization_cookie
  cookies["session_token"] = "gir7nKs/L502O3MpBzkF7RwmUbjZpCw3AU/wEYILeSj8mR75jiqctml0U77UwkSII0v8LjsjlZMI2Vxx8VOtIQhAtmb1DxMwAThapI1GE9e2xgHInVo2sOXu9i6mh5Jnpw==--P972pwxiT1N1w2jV--Jr7SHvdlHtGCYVeUTJRtTw=="
end

def create_user_with_result(params = {})
  default_date = (Time.now - 10.days).to_s
  User::Operation::Create.call(
    params: {
      user: {
        name: params[:name] || random_user_name,
        email: params[:email] || random_email,
        profile_url: params[:profile_url] || "https://example.com/profile/12345",
        chat_url: params[:chat_url] || "https://example.com/chat/12345",
        when_timestamp: params[:when_timestamp] || "07/12/2022 9:30",
        request_timestamp: params[:request_timestamp] || default_date,
        join_timestamp: params[:join_timestamp] || default_date,
        status: params[:status] || "Pending",
        joined: params[:joined],
        location: params[:location] || "Austin, Texas",
        questions_responses: params[:questions_responses] || mock_qna,
        notes: params[:notes] || "this are notes",
        referral: params[:referral] || "referral name",
        greeter_id: params[:greeter_id],
        shadow_greeter_id: params[:shadow_greeter_id]
      }
    }
  )
end

def create_user(params = {})
  create_user_with_result(params)[:model]
end

def create_authorized_user(params = {})
  user = create_user(params)
  user.update(session_token: "H5_LTSXsGWDKkP7V_-aHvA")
  user
end

def login(params = {})
  user = create_authorized_user(params)
  visit login_url(token: user.token)
  user
end

def get_magic_link(user)
  "https://test.emergentcommons.app/login/#{user.token}"
end

def get_unsubscribe_link(user)
  "https://test.emergentcommons.app/unsubscribe/#{user.token}"
end
