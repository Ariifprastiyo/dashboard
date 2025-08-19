FactoryBot.define do
  factory :brand do
    # increment name
    sequence(:name) { |n| "Brand #{n}" }
    description { "MyString" }
    instagram { "MyString" }
    tiktok { "brand_tiktok" }
    logo { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/images/logo.png'), 'image/png') }
  end
end
