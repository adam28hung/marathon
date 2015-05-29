class AddCountOfPhoto < ActiveRecord::Migration
  def change
    add_column :contests, :photo_count, :integer
  end
end
