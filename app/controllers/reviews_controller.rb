class ReviewsController < ApplicationController
  before_action :set_review, only: %i[ show update destroy ]

  # GET /reviews
  def index
    page = params.fetch(:page, 1).to_i
    limit = params.fetch(:limit, 20).to_i

    page = 1 if page < 1
    limit = 20 if limit < 1

    total_count = Review.count
    total_pages = (total_count.to_f / limit).ceil
    offset = (page - 1) * limit

    reviews = Review.order(created_at: :desc).limit(limit).offset(offset)

    render json: {
      data: reviews,
      meta: { page:, limit:, total_count:, total_pages: }
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
