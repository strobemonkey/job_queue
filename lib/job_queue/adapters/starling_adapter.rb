require 'memcache'
require 'starling'

class JobQueue::StarlingAdapter
  def initialize(queue_name, server, port)
    @queue_name = queue_name
    @server = server
    @port = port
    @starling = Starling.new( @server + ':' + @port )
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
        sleep 0.25
      rescue => e        
        error_report.call(job, e)
      end
    end

  end
end
