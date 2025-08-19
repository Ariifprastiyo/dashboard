# frozen_string_literal: true

namespace :mediarumu do
  desc "Seed Category"
  task category: :environment do
    [
      "Beauty",
      "Fashion",
      "Fitness",
      "Foodies",
      "Cooking",
      "Travel",
      "Art",
      "Photography",
      "Lifestyle",
      "Personal development",
      "Animal Lovers",
      "Humor",
      "Entertainment",
      "Technology and gadgets",
      "Automotive and motorsports",
      "Sports",
      "Nature",
      "Home Decor",
      "Parenting and family",
      "DIY and crafting",
      "Business and entrepreneurship",
      "Environmentalism and, sustainability",
      "Personal finance and money management",
      "Spirituality and religion",
      "Gaming",
      "Political activism and advocacy",
      "KPop",
      "Local businesses and shops",
      "Musicians",
      "Book lovers and literature",
      "Magic and illusions",
      "Gardening and horticulture",
      "Moms",
      "Gym Enthusiast",
      "Runner",
      "Cyclist",
      "Gen Z",
      "Young Professional",
      "Story Teller",
      "Movie Enthusiast",
      "Academician",
      "Dance",
      "Medical"
    ].each do |name|
      category = Category.find_or_create_by(name: name)
      Category.create(name: category) if category.new_record?
    end
  end
end
