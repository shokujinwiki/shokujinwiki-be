class ApplicationController < ActionController::API
  include Authentication
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

    def render_error(message:, status:, details: nil)
      body = { error: { message: } }
      body[:error][:details] = details if details
      render json: body, status:
    end

    def bad_request(exception)
      render_error(message: exception.message, status: :bad_request)
    end

    def record_not_found(exception)
      render_error(message: "#{exception.model} not found", status: :not_found)
    end
end
