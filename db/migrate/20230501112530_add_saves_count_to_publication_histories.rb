class AddSavesCountToPublicationHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :publication_histories, :saves_count, :bigint, null: false, default: 0
  end
end
