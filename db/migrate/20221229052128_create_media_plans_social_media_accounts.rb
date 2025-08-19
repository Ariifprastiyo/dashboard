class CreateMediaPlansSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    create_join_table :media_plans, :social_media_accounts
  end
end
