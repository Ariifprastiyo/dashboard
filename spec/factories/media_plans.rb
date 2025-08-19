FactoryBot.define do
  factory :media_plan do
    sequence(:name) { |n| "Media Plan #{n}" }
    estimated_impression { 1.5 }
    estimated_reach { 1.5 }
    estimated_engagement_rate { 1.5 }
    estimated_engagement_rate_branding_post { 1.5 }
    estimated_budget { "9.99" }
    campaign { create(:campaign) }
    scope_of_work_template { { live: 1, story: 2 } }

    trait(:empty) do
      estimated_impression { 0 }
      estimated_reach { 0 }
      estimated_engagement_rate { 0 }
      estimated_engagement_rate_branding_post { 0 }
      estimated_budget { 0 }
      campaign { }
      scope_of_work_template { { live: 0, story: 0 } }
    end
  end
end
