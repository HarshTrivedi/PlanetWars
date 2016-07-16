require 'pstore'
class Storage
	@@store = PStore.new(File.join(  ENV['HOME'] ,".planet_wars.pstore"))

	def self.username=(username)
		@@store.transaction{ @@store[:username] =  username}
	end

	def self.username
		@@store.transaction{ @@store[:username] } 	
	end

	def self.main_server_ip=(main_server_ip)
		@@store.transaction{ @@store[:main_server_ip] =  main_server_ip}
	end

	def self.main_server_ip
		@@store.transaction{ @@store[:main_server_ip] } 	
	end

	def self.main_server_port=(main_server_port)
		@@store.transaction{ @@store[:main_server_port] =  main_server_port}
	end

	def self.main_server_port
		@@store.transaction{ @@store[:main_server_port] } 	
	end

end
