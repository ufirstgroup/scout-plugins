require File.expand_path('../../test_helper.rb', __FILE__)
require File.expand_path('../puppet_last_run.rb', __FILE__)

class PuppetLastRunTest < Test::Unit::TestCase
  
  def setup
    @options=parse_defaults("puppet_last_run")
  end
  
  def test_with_recent_runs
    plugin=PuppetLastRun.new(nil,{},{:data_file => File.expand_path('../fixtures/recent_runs.yaml', __FILE__)})
    result = plugin.run
    report = result[:reports].first
    assert_equal 1, report[:success]
  end
  
  def test_with_last_run_summary
    plugin=PuppetLastRun.new(nil,{},{:data_file => File.expand_path('../fixtures/last_run_summary.yaml', __FILE__)})
    result = plugin.run
    reports = result[:reports].first
    assert_equal 5, reports.size
    reports.each do |k,v|
      assert_not_nil v
    end
  end
  
end