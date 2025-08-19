FactoryBot.define do
  factory :publication_history do
    social_media_publication { nil }
    likes_count { 1 }
    comments_count { 1 }
    impressions { 1 }
    reach { 1 }
    engagement_rate { 1.0 }
    share_count { 1 }
  end
end
