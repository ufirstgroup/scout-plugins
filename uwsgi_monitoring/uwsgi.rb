
class SimplePlugin < Scout::Plugin
    needs 'json'

    OPTIONS=<<-EOS
        location:
            name: Status location
            default: "127.0.0.1:1717"
    EOS

    def build_report
        location = option(:location) || '127.0.0.1:1717'
        hostname, port = location.split(':')

        s = TCPSocket.open(hostname, port.to_i)
        data = JSON.parse(s.read)

        total_requests = 0
        data['workers'].each { |worker| 
            total_requests += worker['requests']
        }

        counter(:requests_per_sec, total_requests, :per => :second)
    end
end
