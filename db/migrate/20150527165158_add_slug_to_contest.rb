class AddSlugToContest < ActiveRecord::Migration
  def change
    add_column :contests, :slug, :string, :unique => true
  end
end
