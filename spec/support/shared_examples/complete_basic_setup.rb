module CompleteBasicSetup
  extend RSpec::SharedContext

  after do
    Timecop.return
  end

  before do
    Timecop.freeze(Time.local(2018, 1, 1, 12, 0, 0))
    # create Brand : Downy
    brand = create(:brand, name: 'Downy')

    # create Campaign : HarumBanget, set KPI's
    campaign = create(:campaign, brand: brand, status: 'active', platform: "instagram", start_at: Date.today, end_at: 30.days.from_now)
    @campaign = campaign
    # Create MediaPlan ALT 1, with template 1 feed_video
    @media_plan = create(:media_plan, :empty, name: "ALT 1", campaign: campaign, scope_of_work_template: { feed_video: 1 })

    # create 2 Mega KOL =>
    mega_1 = create(:social_media_account, :instagram_mega_manual)
    mega_2 = create(:social_media_account, :instagram_mega_manual)

    # create 2 Macro KOL =>
    macro_1 = create(:social_media_account, :instagram_macro_manual)
    macro_2 = create(:social_media_account, :instagram_macro_manual)

    # create 2 Micro KOL =>
    micro_1 = create(:social_media_account, :instagram_micro_manual)
    micro_2 = create(:social_media_account, :instagram_micro_manual)

    # create 2 Nano KOL =>
    nano_1 = create(:social_media_account, :instagram_nano_manual)
    nano_2 = create(:social_media_account, :instagram_nano_manual)

    # Insert all KOL to MediaPlan (SOW)
    [mega_1, mega_2, macro_1, macro_2, micro_1, micro_2, nano_1, nano_2].each do |acc|
      create(:scope_of_work, media_plan: @media_plan, social_media_account: acc)
    end

    posted_at = 2.days.ago
    today = Date.today

    # Insert sosmed publication => set posted_at few days ago, set manual
    [mega_1, mega_2, macro_1, macro_2, micro_1, micro_2, nano_1, nano_2].each do |acc|
      sow = acc.scope_of_works.first
      sow_item = sow.scope_of_work_items.first

      sow_item.posted_at = posted_at
      # mark up sell price
      sow_item.sell_price = (sow_item.price * 1.2).to_i
      sow_item.save



      # Initial must be 0 for all metrics
      pub = create(:social_media_publication,
                    manual: true,
                    url: acc.username,
                    platform: :instagram,
                    scope_of_work: sow,
                    scope_of_work_item: sow_item,
                    campaign_id: campaign.id,
                    social_media_account_id: acc.id,
                    post_created_at: posted_at,
                    caption: "caption #{acc}",
                    likes_count: 0,
                    comments_count: 0,
                    impressions: 0,
                    reach: 0,
                    engagement_rate: 0,
                    share_count: 0,
                    last_sync_at: Time.now)

      ph = PublicationHistory.create_from_social_media_publication(pub)

      ph.update(created_at: posted_at, comments_count: 0, related_media_comments_count: 0)

      # create comments
      how_many_related_comments = { "nano" => 1, "micro" => 2, "macro" => 3, "mega" => 4 }
      how_many_related_comments[acc.size].times do
        related_comment = create(:media_comment, platform: 'instagram', social_media_publication: pub)
        related_comment.update(related_to_brand: true)
      end

      8.times do
        comment = create(:media_comment, platform: 'instagram', social_media_publication: pub)
        comment.update(related_to_brand: false)
      end
      # end create comments

      # simulate after sync_daily_update
      # MAKE SURE need to populate everything
      how_many_likes_count = { "nano" => 100, "micro" => 200, "macro" => 3_000, "mega" => 40_000 }
      how_many_impressions = { "nano" => 1_000, "micro" => 2_000, "macro" => 30_000, "mega" => 400_000 }

      er = ((how_many_likes_count[acc.size] + how_many_related_comments[acc.size] + 8) / how_many_impressions[acc.size].to_f) * 100

      pub_history = create(:publication_history,
                            social_media_account_size: acc.size,
                            social_media_account: acc,
                            platform: pub.platform,
                            social_media_publication: pub,
                            likes_count: how_many_likes_count[acc.size],
                            campaign: campaign,
                            impressions: how_many_impressions[acc.size],
                            reach: how_many_impressions[acc.size] * 2,
                            engagement_rate: er,
                            share_count: 0,
                            related_media_comments_count: how_many_related_comments[acc.size],
                            comments_count: 8 + how_many_related_comments[acc.size])
      pub_history.update(created_at: today)

      @pub = pub
      @ph = pub_history
    end
  end
end
