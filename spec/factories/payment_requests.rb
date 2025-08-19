FactoryBot.define do
  factory :payment_request do
    campaign { create(:campaign) }
    requestor { create(:user) }
    beneficiary { create(:social_media_account, :instagram_mega_manual) }
    amount { 1 }
    due_date { "2023-03-14" }
    paid_at { "2023-03-14" }
    invoice { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/images/logo.png'), 'image/png') }
    payer { nil }
    pph_option { :gross_up }
    ppn { false }

    trait :pending do
      status { :pending }
    end

    trait :processed do
      status { :processed }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :paid do
      status { :paid }
    end
  end
end
