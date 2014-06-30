class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :key_value
      t.string :key_type
      t.string :name
      t.string :priority_type
      t.string :priority_value

      t.timestamps
    end
  end
end
