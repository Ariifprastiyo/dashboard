class AddLastSubmittedAtToScopeOfWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :scope_of_works, :last_submitted_at, :datetime
  end
end
