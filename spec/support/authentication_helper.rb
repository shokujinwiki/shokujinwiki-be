module AuthenticationHelper
  def auth_headers_for(user)
    session = user.sessions.create!(user_agent: "RSpec", ip_address: "127.0.0.1")
    {
      "Authorization" => "Bearer #{session.token}"
    }
  end
end
