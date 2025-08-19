class AddCommentAiToCampaigns < ActiveRecord::Migration[7.1]
  def change
    add_column :campaigns, :comment_ai_prompt, :string
    add_column :campaigns, :comment_ai_analysis, :text
    add_column :campaigns, :comment_ai_payload_result, :text
    add_column :media_comments, :sentiment_analysis, :integer, default: 0
  end
end
