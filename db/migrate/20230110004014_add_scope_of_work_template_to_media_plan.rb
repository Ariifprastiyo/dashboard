class AddScopeOfWorkTemplateToMediaPlan < ActiveRecord::Migration[7.0]
  def change
    add_column :media_plans, :scope_of_work_template, :jsonb
  end
end
