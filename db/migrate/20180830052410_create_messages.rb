class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :category
      t.string :text
      t.datetime :from_at
      t.datetime :to_at

      t.timestamps
    end
  end
end
