class AddAccessTokenToMembers < ActiveRecord::Migration
  def change
    add_column :members, :access_token, :string
    add_column :members, :token_expires_at, :datetime
    add_column :members, :refresh_token, :string
  end
end
