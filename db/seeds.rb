Session.delete_all
Review.delete_all
User.delete_all

users = [
  { name: "Alice", email_address: "alice@example.com" },
  { name: "Bob", email_address: "bob@example.com" },
  { name: "Charlie", email_address: "charlie@example.com" }
]

users.each do |attrs|
  user = User.create!(password: "password123", **attrs)
  10.times do |i|
    Review.create!(
      content: "#{attrs[:name]} review #{i + 1}",
      user:
    )
  end
end

puts "Created #{User.count} users and #{Review.count} reviews"
