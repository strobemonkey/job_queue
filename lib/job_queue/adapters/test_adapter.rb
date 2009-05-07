class JobQueue::TestAdapter
  def initialize(options = {})
    @queue = []
  end
  
  def put(string)
    @queue << string
  end
  
  def subscribe(error_report, &block)
    loop do
      begin
        if @queue.empty? then sleep 0.1 ; end
        yield @queue.shift
      rescue => e        
        error_report.call(@queue, e)
      end
    end
  end
end
