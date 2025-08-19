# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

OrganizationSetting.create(name: "Media Rumu")
# create default role
User::ROLES.each do |role|
  Role.find_or_create_by(name: role)
end


# create admin
user = User.create(name: "Admin", email: "admin@email.com", password: "password", password_confirmation: "password")
user.add_role :super_admin

# create categories
["Beauty", "Fashion", "Food", "Lifestyle", "Travel"].each do |category|
  Category.create(name: category)
end

# Create influencers
influencers = []
i = Influencer.create(name: "Tasya Kamila", pic_phone_number: "081212128282", pic: 'PIC', no_npwp: '12345678' )
FactoryBot.create(:social_media_account, username: "tasyakamila", influencer: i, platform: :instagram)
begin
  FactoryBot.create(:social_media_account, username: "tasyakamilaofficial", influencer: i, platform: :tiktok)
rescue TikapiProfileService::TikapiProfileNotFound => e
  puts e.message
end
influencers << i

i = Influencer.create(name: "Fadil Jaidi", pic_phone_number: "08121299992", pic: 'PIC', no_npwp: '12345678')
FactoryBot.create(:social_media_account, username: "fadiljaidi", influencer: i, platform: :instagram)
begin
  FactoryBot.create(:social_media_account, username: "fadiljaidi", influencer: i, platform: :tiktok)
rescue TikapiProfileService::TikapiProfileNotFound => e
  puts e.message
end 
influencers << i

i = Influencer.create(name: "Vina", pic_phone_number: "08121299992", pic: 'PIC', no_npwp: '12345678')
FactoryBot.create(:social_media_account, username: "adhytia", influencer: i, platform: :instagram)

begin
  FactoryBot.create(:social_media_account, username: "keluargaburw", influencer: i, platform: :tiktok)
rescue TikapiProfileService::TikapiProfileNotFound => e
  puts e.message
end

influencers << i

i = Influencer.create(name: "Adit Toro", pic_phone_number: "08121299992", pic: 'PIC', no_npwp: '12345678')
FactoryBot.create(:social_media_account, username: "adittoro", influencer: i, platform: :instagram)
influencers << i

# Create brands
b = Brand.create(name: "Brand 1")

# create Campaigns
c = Campaign.create(name: "Campaign 1", brand: b, start_at: Date.today, end_at: Date.today + 1.month, platform: :instagram, status: :active, kpi_number_of_social_media_accounts: 1, kpi_engagement_rate: 1.5, kpi_reach: 1.5, kpi_impression: 1.5, kpi_cpv: 1.5, kpi_cpr: 1.5, budget: 1000000)

# create media plans
scope_of_work_template = ScopeOfWorkItem::PRICES.map { |price| [price, 1] }.to_h
mp = MediaPlan.create(campaign: c, name: "Media Plan 1", scope_of_work_template: scope_of_work_template)

# create management

management = Management.create(name: 'Management')
social_media_account_management = FactoryBot.create(:social_media_account, :instagram_nano_manual)
management.social_media_accounts << social_media_account_management

# create media plan influencers
# instagram_accounts = SocialMediaAccount.where(platform: :instagram)
# mp.social_media_accounts << instagram_accounts
# mp.save

# Create social media posts
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?