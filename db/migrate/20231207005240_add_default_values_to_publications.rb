class AddDefaultValuesToPublications < ActiveRecord::Migration[7.1]
  def up
    change_column_default :bulk_publications, :total_error, 0
    change_column_default :bulk_publications, :total_row, 0
    change_column_default :bulk_publications, :current_row, 0
    change_column_default :bulk_publications, :error_messages, []
  end

  def down
    change_column_default :bulk_publications, :total_error, nil
    change_column_default :bulk_publications, :total_row, nil
    change_column_default :bulk_publications, :current_row, nil
    change_column_default :bulk_publications, :error_messages, nil
  end
end
