class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  # POST /registration
  def create
    user = User.new(user_params)

    if user.save
      session = start_new_session_for(user)
      render json: { token: session.token }, status: :created
    else
      render_error(message: "Validation failed", details: user.errors.messages, status: :unprocessable_content)
    end
  end

  private

    def user_params
      params.permit(:name, :email_address, :password)
    end
end
