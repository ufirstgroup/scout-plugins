class CephPlugin < Scout::Plugin
  
  class CephStatus
  
    HEALTH_OK = "HEALTH_OK"
  
    def initialize(status)
      @status_text = status
      parse
    end
  
    def parse
      @lines = @status_text.split("\n").map { |line| line.strip }
      @status = {}
      @status[:health] = @lines[0].split(' ')[1]
      @status[:unhealthy_reason] = @lines[0].split(' ')[2..-1].join(' ') rescue nil
      @status[:num_osds] = @lines[2].match(/(\d*)\sosds:/)[1].to_i
      @status[:osds_up] = @lines[2].match(/(\d*)\sup/)[1].to_i
      @status[:osds_in] = @lines[2].match(/(\d*)\sin/)[1].to_i
      @status[:data_size] = @lines[3].match(/\s(\d*\s[A-Z]{2})\sdata/)[1]
      @status[:used] = @lines[3].match(/\s(\d*\s[A-Z]{2})\sused/)[1]
      @status[:available] = @lines[3].match(/\s(\d*\s[A-Z]{2})\s\//)[1]
      @status[:cluster_total_size] = @lines[3].match(/\s(\d*\s[A-Z]{2})\savail/)[1]
      @status[:capacity] = "#{((@status[:used].to_f / @status[:cluster_total_size].to_f)*100).round(0)}%"
    end
  
    def cluster_ok?
      @status[:health] == HEALTH_OK
    end
    
    def to_h
      @status
    end
  
    def method_missing(sym, *args, &block)
      if @status.key?(sym)
        @status[sym]
      else
        super
      end
    end
  
  end
  
  def new_ceph_status
    CephStatus.new(`ceph -s`.chomp)
  end
  
  def build_report
    ceph_status = new_ceph_status
    unless ceph_status.cluster_ok?
      alert("Ceph is unhealthy", "current status: #{ceph_status.health} - #{ceph_status.unhealthy_reason}")
    end
    report(ceph_status.to_h)
  end
  
end