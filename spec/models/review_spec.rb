require 'rails_helper'

RSpec.describe Review do
  it "is valid with valid attributes" do
    review = build(:review, content: "hello")
    expect(review).to be_valid
  end

  it "is not valid without content" do
    review = build(:review, content: nil)
    expect(review).not_to be_valid
  end
end
