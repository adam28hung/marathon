class AddEventDateToContests < ActiveRecord::Migration
  def change
    add_column :contests, :event_date, :date
  end
end
