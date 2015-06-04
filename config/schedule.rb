env :PATH, ENV['PATH']

set :output, 'log/whenever.log'

every :day, :at => '3am'  do
  rake "whenever:check_latest_contest"
end