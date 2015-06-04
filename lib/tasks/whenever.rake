#encoding: utf-8
namespace :whenever do

  desc "check for new contest"
  task :check_latest_contest => :environment do
    Contest.check_latest_contest
  end

end