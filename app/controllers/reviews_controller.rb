class ReviewsController < ApplicationController
  include Paginatable

  before_action :set_review, only: [ :show, :update, :destroy ]
  before_action :authorize_owner!, only: [ :update, :destroy ]

  # GET /reviews
  def index
    scope = Review.includes(:user).order(created_at: :desc)
    review, meta = paginate(scope)

    render json: {
      data: ReviewSerializer.many(review),
      meta:
    }
  end

  # GET /reviews/1
  def show
    render json: ReviewSerializer.new(@review).as_json
  end

  # POST /reviews
  def create
    @review = Current.user.reviews.new(review_params)

    if @review.save
      render json: ReviewSerializer.new(@review).as_json, status: :created, location: @review
    else
      render_error(message: "Validation failed", details: @review.errors.messages, status: :unprocessable_content)
    end
  end

  # PATCH/PUT /reviews/1
  def update
    if @review.update(review_params)
      render json: ReviewSerializer.new(@review).as_json
    else
      render_error(message: "Validation failed", details: @review.errors.messages, status: :unprocessable_content)
    end
  end

  # DELETE /reviews/1
  def destroy
    @review.destroy!
  end

  private
    def set_review
      @review = Review.includes(:user).find(params.expect(:id))
    end

    def review_params
      params.expect(review: [ :content ])
    end

    def authorize_owner!
      render_error(message: "Forbidden", status: :forbidden) unless @review.user_id == Current.user.id
    end
end
