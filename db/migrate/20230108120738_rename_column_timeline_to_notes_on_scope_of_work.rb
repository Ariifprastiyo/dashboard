class RenameColumnTimelineToNotesOnScopeOfWork < ActiveRecord::Migration[7.0]
  def change
    rename_column :scope_of_works, :timeline, :notes
  end
end
