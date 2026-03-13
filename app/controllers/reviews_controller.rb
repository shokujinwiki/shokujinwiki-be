class ReviewsController < ApplicationController
  before_action :set_review, only: %i[ show update destroy ]

  # GET /reviews
  def index
    page = params.fetch(:page, 1).to_i
    per = params.fetch(:per, 20).to_i

    page = 1 if page < 1
    per = 20 if per < 1

    total_count = Review.count
    total_pages = (total_count.to_f / per).ceil
    offset = (page - 1) * per

    reviews = Review.order(created_at: :desc).limit(per).offset(offset)

    render json: {
      data: reviews,
      meta: {
        page: page,
        per: per,
        total_count: total_count,
        total_pages: total_pages
      }
    }
  end

  # GET /reviews/1
  def show
    render json: @review
  end

  # POST /reviews
  def create
    @review = Review.new(review_params)

    if @review.save
      render json: @review, status: :created, location: @review
    else
      render json: @review.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /reviews/1
  def update
    if @review.update(review_params)
      render json: @review
    else
      render json: @review.errors, status: :unprocessable_content
    end
  end

  # DELETE /reviews/1
  def destroy
    @review.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def review_params
      params.expect(review: [ :content ])
    end
end
