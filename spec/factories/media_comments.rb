FactoryBot.define do
  factory :media_comment do
    platform { 1 }
    payload { "" }
    related_to_brand { false }
    content { "MyText" }
    social_media_publication { nil }
    platform_id { "MyText" }

    trait :manual_review do
      manually_reviewed_at { Date.today }
    end

    trait :related do
      related_to_brand { true }
    end
  end
end
