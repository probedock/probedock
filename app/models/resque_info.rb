class ResqueInfo
  attr_accessor :jobs, :workers, :queues

  def initialize(jobs, workers, queue_sizes)
    @jobs = jobs
    @workers = workers
    @queues = queue_sizes
  end

  def self.stats()
    resque_info = Resque.info

    jobs = {
      pending: resque_info[:pending],
      processed: resque_info[:processed],
      failed: resque_info[:failed]
    }

    workers = {
      total: resque_info[:workers],
      working: resque_info[:working]
    }

    queues_sizes = []
    Resque.queue_sizes.each do |queue_name, size|
      queues_sizes << {
        name: queue_name,
        size: size
      }
    end

    ResqueInfo.new(jobs, workers, queues_sizes)
  end
end