class ReviewSerializer
  def initialize(review)
    @review = review
  end

  def as_json
    {
      id: @review.id,
      content: @review.content,
      user: {
        id: @review.user.id,
        name: @review.user.name
      },
      created_at: @review.created_at.rfc3339,
      updated_at: @review.updated_at.rfc3339
    }
  end

  def self.many(reviews)
    reviews.map { |review| new(review).as_json }
  end
end
