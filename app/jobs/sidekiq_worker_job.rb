class SidekiqWorkerJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Do something later
    # SidekiqWorkerJob.perform_later(query_page, @contest.objectid, @records_per_request)  
  end
end
