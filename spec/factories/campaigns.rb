FactoryBot.define do
  factory :campaign do
    sequence(:name) { |n| "Campaign #{n}" }
    brand { create(:brand) }
    status { 1 }
    start_at { "2022-12-26 15:29:58" }
    end_at { "2022-12-26 16:29:58" }
    budget { "9.99" }
    kpi_reach { 1.5 }
    kpi_impression { 1.5 }
    kpi_engagement_rate { 1.5 }
    kpi_number_of_social_media_accounts { 1 }
    kpi_cpv { "9.99" }
    kpi_cpr { "9.99" }
    kpi_crb { "90.10" }
    platform { "instagram" }
    invitation_expired_at { "2022-12-31 16:29:58" }
    organization { nil }

    trait :active do
      status { :active }
    end

    trait :draft do
      status { :draft }
    end

    trait :failed do
      status { :failed }
    end

    trait :completed do
      status { :completed }
    end
  end
end
