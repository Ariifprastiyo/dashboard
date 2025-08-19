FactoryBot.define do
  factory :social_media_account do
    influencer { nil }
    sequence(:username) { |n| "username#{n}" }
    platform { "instagram" }
    followers { nil }
    story_price { "9.99" }
    story_session_price { "9.99" }
    feed_photo_price { "9.99" }
    feed_video_price { "9.99" }
    reel_price { "9.99" }
    live_price { "9.99" }
    owning_asset_price { "9.99" }
    last_sync_at { "2022-12-20 09:01:57" }
    estimated_impression { 10 }
    estimated_reach { 8 }
    estimated_engagement_rate { 1.5 }
    estimated_engagement_rate_branding_post { 1.5 }
    estimated_engagement_rate_average { 1.5 }

    trait :manual do
      manual { true }
    end

    trait(:tiktok) do
      platform { 'tiktok' }
      username { 'fadiljaidi' }
      influencer { create(:influencer) }
    end

    trait(:instagram) do
      platform { 'instagram' }
      username { 'fadiljaidi' }
      influencer { create(:influencer) }
    end

    trait(:instagram_mega_manual) do
      manual { true }
      influencer { create(:influencer) }
      sequence(:username) { |n| "mega_#{n}" }
      platform { "instagram" }
      followers { 2_000_000 }
      story_price { "20_000_000" }
      story_session_price { "20_000_000" }
      feed_photo_price { "20_000_000" }
      feed_video_price { "20_000_000" }
      reel_price { "20_000_000" }
      live_price { "20_000_000" }
      owning_asset_price { "20_000_000" }
      last_sync_at { "2022-12-20 09:01:57" }
      estimated_impression { 2_000_000 }
      estimated_reach { 1_800_000 }
      estimated_engagement_rate { 2.5 }
      estimated_engagement_rate_branding_post { 2.5 }
      estimated_engagement_rate_average { 2.5 }
    end

    trait(:instagram_macro_manual) do
      manual { true }
      influencer { create(:influencer) }
      sequence(:username) { |n| "macro_#{n}" }
      platform { "instagram" }
      followers { 200_000 }
      story_price { "2_000_000" }
      story_session_price { "2_000_000" }
      feed_photo_price { "2_000_000" }
      feed_video_price { "2_000_000" }
      reel_price { "2_000_000" }
      live_price { "2_000_000" }
      owning_asset_price { "2_000_000" }
      last_sync_at { "2022-12-20 09:01:57" }
      estimated_impression { 200_000 }
      estimated_reach { 180_000 }
      estimated_engagement_rate { 1.5 }
      estimated_engagement_rate_branding_post { 1.5 }
      estimated_engagement_rate_average { 1.5 }
    end

    trait(:instagram_micro_manual) do
      manual { true }
      influencer { create(:influencer) }
      sequence(:username) { |n| "micro_#{n}" }
      platform { "instagram" }
      followers { 10_000 }
      story_price { "200_000" }
      story_session_price { "200_000" }
      feed_photo_price { "200_000" }
      feed_video_price { "200_000" }
      reel_price { "200_000" }
      live_price { "200_000" }
      owning_asset_price { "200_000" }
      last_sync_at { "2022-12-20 09:01:57" }
      estimated_impression { 20_000 }
      estimated_reach { 18_000 }
      estimated_engagement_rate { 3.5 }
      estimated_engagement_rate_branding_post { 3.5 }
      estimated_engagement_rate_average { 3.5 }
    end

    trait(:instagram_nano_manual) do
      manual { true }
      influencer { create(:influencer) }
      sequence(:username) { |n| "nano_#{n}" }
      platform { "instagram" }
      followers { 1_000 }
      story_price { "20_000" }
      story_session_price { "20_000" }
      feed_photo_price { "20_000" }
      feed_video_price { "20_000" }
      reel_price { "20_000" }
      live_price { "20_000" }
      owning_asset_price { "20_000" }
      last_sync_at { "2022-12-20 09:01:57" }
      estimated_impression { 2_000 }
      estimated_reach { 1_000 }
      estimated_engagement_rate { 2.5 }
      estimated_engagement_rate_branding_post { 2.5 }
      estimated_engagement_rate_average { 2.5 }
    end
  end
end
