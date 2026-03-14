require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = build(:user, name: "Alice")
    expect(user).to be_valid
  end

  it "is not valid without name" do
    user = build(:user, name: nil)
    expect(user).not_to be_valid
  end
end
