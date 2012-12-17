require File.expand_path('../../test_helper.rb', __FILE__)
require File.expand_path('../redis-info.rb', __FILE__)


class RedisMonitorTest < Test::Unit::TestCase
  def test_default_to_host_and_port
    plugin = RedisMonitor.new(nil,{},{})
    res = plugin.run
    assert error = res[:errors].first
    assert error[:body].include?("connect to Redis on 127.0.0.1:6379")
    assert error[:body].include?("correct host and port")
  end
  
  def test_unix_socket_path_override
    plugin = RedisMonitor.new(nil,{},{:client_host => 'notused.com', :client_port => '9999', :client_path => '/tmp/redis.sock'})
    res = plugin.run
    assert error = res[:errors].first
    assert error[:body].include?("/tmp/redis.sock")
    assert error[:body].include?("correct Unix socket path")
  end
end