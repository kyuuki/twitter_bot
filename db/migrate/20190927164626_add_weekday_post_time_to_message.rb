class AddWeekdayPostTimeToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :post_weekday, :integer
    add_column :messages, :post_time, :time
  end
end
