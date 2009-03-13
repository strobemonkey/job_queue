require File.dirname(__FILE__) + '/spec_helper'

describe JobQueue::StarlingAdapter do
  
  def fairly_unique_message
    rand(0.1).to_s.split('.')[1]
  end
  
  before :all do
    JobQueue.adapter = JobQueue::StarlingAdapter.new( 'test_queue', 'localhost', '22122' )
  end
  
  it "should write onto queue and fetch stuff back off" do    
    message = fairly_unique_message
    JobQueue.put(message)
    
    JobQueue.subscribe do |job|
      @job = job
      throw :stop
    end
    
    @job.should == message
  end
  
  it "should output message if error raised in job" do    
    message = fairly_unique_message
    JobQueue.put(message)
    
    JobQueue.logger.should_receive(:error).with(/Job failed\w*/)

    index = 0
    JobQueue.subscribe do |job|
      index +=1
      raise 'foo' if index == 1
      throw :stop
    end
  end
  
  it "should use error_report block if supplied" do
    message = fairly_unique_message
    JobQueue.put(message)
    
    error_report = Proc.new do |job, e|
      JobQueue.logger.error "Yikes that broke matey!"
    end
    
    JobQueue.logger.should_receive(:error).with("Yikes that broke matey!")
    
    index = 0
    JobQueue.subscribe(error_report) do |job|
      index +=1
      raise 'foo' if index == 1
      throw :stop
    end
  end
end
