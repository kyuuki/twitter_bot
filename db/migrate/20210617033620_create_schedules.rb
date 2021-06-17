class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.integer :category
      t.integer :post_weekday
      t.time :post_time

      t.timestamps
    end
  end
end
