class AddPicturePageToMember < ActiveRecord::Migration
  def change
    add_column :members, :picture, :string
    add_column :members, :info_page, :string
  end
end
