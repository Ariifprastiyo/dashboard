class AddEmbeddingToMediaComments < ActiveRecord::Migration[8.0]
  def change
    add_column :media_comments, :embedding, :vector, limit: 1536
  end
end
