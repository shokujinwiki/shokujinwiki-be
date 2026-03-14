class ApplicationController < ActionController::API
  include Authentication
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

    def bad_request(exception)
      render json: {
        message: exception.message
      }, status: :bad_request
    end

    def record_not_found(exception)
      render json: {
        message: "#{exception.model} not found"
      }, status: :not_found
    end
end
