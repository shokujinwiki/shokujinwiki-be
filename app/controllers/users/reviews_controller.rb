class Users::ReviewsController < ApplicationController
  include Paginatable

  def index
    user = User.find(params[:user_id])

    scope = user.reviews.includes(:user).order(created_at: :desc)
    reviews, meta = paginate(scope)

    render json: {
      data: ReviewSerializer.many(reviews),
      meta:
    }
  end
end
