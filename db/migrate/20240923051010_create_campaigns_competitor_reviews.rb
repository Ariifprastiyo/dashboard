class CreateCampaignsCompetitorReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :campaigns_competitor_reviews do |t|
      t.belongs_to :campaign
      t.belongs_to :competitor_review
      t.timestamps
    end
  end
end
