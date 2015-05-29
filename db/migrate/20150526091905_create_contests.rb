class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.string :objectid
      t.string :name
      t.string :place
      t.date :date_created_on_parse

      t.timestamps null: false
    end
  end
end
