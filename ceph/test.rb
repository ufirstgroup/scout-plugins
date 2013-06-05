require File.expand_path('../../test_helper.rb', __FILE__)
require File.expand_path('../ceph.rb', __FILE__)

class CephTest < Test::Unit::TestCase
    # Stub the plugin instance where necessary and run
    # @plugin=PluginName.new(last_run, memory, options)
    #                        date      hash    hash
    
    def test_success_run
      data = IO.binread(File.dirname(__FILE__)+'/fixtures/ceph_ok')
      plugin = CephPlugin.new(nil, {}, {})
      ceph_status = CephPlugin::CephStatus.new(data)
      plugin.stubs(:new_ceph_status).returns(ceph_status)
      plugin.expects(:report).with(ceph_status.to_h)
      res = plugin.run
    end
    
    def test_success_status
      data = IO.binread(File.dirname(__FILE__)+'/fixtures/ceph_ok')
      plugin = CephPlugin.new(nil, {}, {})
      ceph_status = CephPlugin::CephStatus.new(data)
      plugin.stubs(:new_ceph_status).returns(ceph_status)
      res = plugin.run
      assert_equal "HEALTH_OK", res[:reports].first[:health]
      assert_equal "411 GB", res[:reports].first[:data_size]
      assert_equal "634 GB", res[:reports].first[:used]
      assert_equal "1314 GB", res[:reports].first[:available]
      assert_equal "2024 GB", res[:reports].first[:cluster_total_size]
      assert_equal 2, res[:reports].first[:num_osds]
      assert_equal 2, res[:reports].first[:osds_up]
      assert_equal 2, res[:reports].first[:osds_in]
    end
    
    def test_error_run
      data = IO.binread(File.dirname(__FILE__)+'/fixtures/ceph_unhealthy')
      plugin = CephPlugin.new(nil, {}, {})
      ceph_status = CephPlugin::CephStatus.new(data)
      plugin.stubs(:new_ceph_status).returns(ceph_status)
      plugin.expects(:report).with(ceph_status.to_h)
      res = plugin.run
    end
    
    def test_error_status
      data = IO.binread(File.dirname(__FILE__)+'/fixtures/ceph_unhealthy')
      plugin = CephPlugin.new(nil, {}, {})
      ceph_status = CephPlugin::CephStatus.new(data)
      plugin.stubs(:new_ceph_status).returns(ceph_status)
      res = plugin.run
      assert_equal "HEALTH_WARN", res[:reports].first[:health]
      assert_equal "2304 pgs degraded; 2304 pgs stuck unclean; recovery 306763/613526 degraded (50.000%); 1/2 in osds are down", res[:reports].first[:unhealthy_reason]
      assert_equal "411 GB", res[:reports].first[:data_size]
      assert_equal "760 GB", res[:reports].first[:used]
      assert_equal "1191 GB", res[:reports].first[:available]
      assert_equal "2024 GB", res[:reports].first[:cluster_total_size]
      assert_equal 2, res[:reports].first[:num_osds]
      assert_equal 1, res[:reports].first[:osds_up]
      assert_equal 2, res[:reports].first[:osds_in]
    end
    
  
end
#health HEALTH_WARN 2304 pgs degraded; 2304 pgs stuck unclean; recovery 306763/613526 degraded (50.000%); 1/2 in osds are down
#monmap e1: 1 mons at {a=10.62.202.65:6789/0}, election epoch 0, quorum 0 a
#osdmap e978: 2 osds: 1 up, 2 in
# pgmap v858992: 2304 pgs: 2304 active+degraded; 411 GB data, 760 GB used, 1191 GB / 2024 GB avail; 306763/613526 degraded (50.000%)
#mdsmap e1: 0/0/1 up

#@status[:health] = @lines[0].split(' ')[1]
#@status[:unhealthy_reason] = @lines[0].split(' ')[2..-1].join(' ') rescue nil
#@status[:num_osds] = @lines[2].match(/(\d*)\sosds:/)[1].to_i
#@status[:osds_up] = @lines[2].match(/(\d*)\sup/)[1].to_i
#@status[:osds_in] = @lines[2].match(/(\d*)\sin/)[1].to_i
#@status[:data_size] = @lines[3].match(/\s(\d*\s[A-Z]{2})\sdata/)[1]
#@status[:used] = @lines[3].match(/\s(\d*\s[A-Z]{2})\sused/)[1]
#@status[:available] = @lines[3].match(/\s(\d*\s[A-Z]{2})\s\//)[1]
#@status[:cluster_total_size] = @lines[3].match(/\s(\d*\s[A-Z]{2})\savail/)[1]