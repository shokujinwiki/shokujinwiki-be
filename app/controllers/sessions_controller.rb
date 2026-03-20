class SessionsController < ApplicationController
  allow_unauthenticated_access only: [ :create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render_error(message: "Too many requests. Please try again later.", status: :too_many_requests) }

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      session = start_new_session_for(user)
      render json: {
        token: session.token
      }, status: :created
    else
      render_error(message: "Invalid email address or password.", status: :unauthorized)
    end
  end

  def destroy
    terminate_session
    head :no_content
  end
end
