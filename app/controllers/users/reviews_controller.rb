class Users::ReviewsController < ApplicationController
  DEFAULT_LIMIT = 20
  MAX_LIMIT = 100

  def index
    user = User.find(params[:user_id])

    page = params.fetch(:page, 1).to_i
    limit = params.fetch(:limit, DEFAULT_LIMIT).to_i

    page = 1 if page < 1
    limit = limit.clamp(1, MAX_LIMIT)

    total_count = user.reviews.count
    total_pages = (total_count.to_f / limit).ceil
    offset = (page - 1) * limit

    reviews = user.reviews
                  .includes(:user)
                  .order(created_at: :desc)
                  .limit(limit)
                  .offset(offset)

    next_page = page < total_pages ? page + 1 : nil
    prev_page = page > 1 ? page - 1 : nil

    render json: {
      data: reviews.map { |review| review_json(review) },
      meta: {
        page:,
        limit:,
        total_count:,
        total_pages:,
        next_page:,
        prev_page:
      }
    }
  end

  private

    def review_json(review)
      {
        id: review.id,
        content: review.content,
        user: {
          id: review.user.id,
          name: review.user.name
        },
        created_at: review.created_at.rfc3339,
        updated_at: review.updated_at.rfc3339
      }
    end
end
