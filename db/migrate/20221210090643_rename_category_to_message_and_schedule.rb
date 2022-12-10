class RenameCategoryToMessageAndSchedule < ActiveRecord::Migration[5.2]
  def change
    rename_column :messages, :category, :category_id
    rename_column :schedules, :category, :category_id
  end
end
