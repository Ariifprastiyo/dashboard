FactoryBot.define do
  factory :social_media_publication do
    post_identifier { "MyString" }
    kind { 1 }
    url { "MyString" }
    post_created_at { "2023-01-09 20:00:20" }
    caption { "MyText" }
    comments_count { 0 }
    likes_count { 0 }
    share_count { 0 }
    impressions { 0 }
    reach { 0 }
    engagement_rate { 0 }
    last_sync_at { "2023-01-09 20:00:20" }
    payload { "" }
    social_media_account { nil }
    platform { nil }
    manual { false }

    trait(:instagram) do
      platform { 'instagram' }
      social_media_account { create(:social_media_account, :instagram) }
    end

    trait(:tiktok) do
      platform { 'tiktok' }
      social_media_account { create(:social_media_account, :tiktok) }
    end
  end
end
