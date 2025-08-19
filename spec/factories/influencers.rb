FactoryBot.define do
  factory :influencer do
    sequence(:name) { |n| "Influencer #{n}" }
    pic_phone_number { "MyString" }
    pic { "MyString" }
    no_npwp { '1099232312233' }
    have_npwp { true }
    gender { 1 }
    bank_code { 'bca' }
  end
end
