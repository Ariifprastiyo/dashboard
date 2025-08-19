class AddHaveNpwpToInfluencers < ActiveRecord::Migration[7.0]
  def change
    add_column :influencers, :have_npwp, :boolean, default: true
  end
end
