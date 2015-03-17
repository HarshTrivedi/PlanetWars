require 'socket'
require 'timeout'
class Address

	def self.open?(ip , port)
        begin
            Timeout::timeout(1) do
	            begin
		            s = TCPSocket.new(ip, port.to_i)
		            s.close
		            return false
		            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
		            return true
	            end
            end
        	rescue Timeout::Error
        end
        return true
    end

    def self.open_port(ip="localhost" , start_port=3000 , end_port=4000 )
        until start_port == end_port do
            return start_port if open?(ip , start_port )
            start_port +=1
        end
    end

    def self.local_ip
    	Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
    	#OR
    	#UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
    end


end