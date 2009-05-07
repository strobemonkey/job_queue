require 'memcache'
require 'starling'

class JobQueue::StarlingAdapter
  def initialize(options = {})
    @queue_name = options[:host] || 'no_queue_name'
    host = options[:host] || 'localhost'
    port = options[:port] || '22122'   
    @starling = Starling.new( host + ':' + port )
  end

  def put(string)
    @starling.set(@queue_name, string)
  end

  def subscribe(error_report, &block)

    loop do
      begin
        job = @starling.fetch(@queue_name)
        JobQueue.logger.info "Starling received #{job}" 
        yield job
      rescue => e        
        error_report.call(job, e)
      end
    end

  end
end
