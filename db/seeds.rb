# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Review.delete_all
User.delete_all

user_attrs = [
  { name: "Alice" },
  { name: "Bob" },
  { name: "Charlie" }
]

user_attrs.each do |attrs|
  user = User.create!(attrs)
  10.times do |i|
    Review.create!(
      content: "#{attrs[:name]} review #{i + 1}",
      user:
    )
  end
end
