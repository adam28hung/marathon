class MonitController < ApplicationController
  before_action :authenticate_admin!

  private

  def after_sign_out_path_for(current_admin)
    root_path
  end

end