require 'Connection'

require 'socket'
class InternalServer
	##to do: Rememeber to initialize PlanetWars.player_id and opponenet_id for each player app seperately(IMP)
	## if this app acts as server, its player_id should be set 1 , and opponenet_id must be set 2
	def initialize( ip , port)
	    @server = TCPServer.open( ip, port )
	    @opponenet_machine = @server.accept 
	    Connection.connection = self
	end

	def listen_to_opponent
		Thread.new do
			loop do
				recieved_message_string = @opponenet_machine.gets
				source_planet_id , destination_planet_id = recieved_message_string.split(",").map(&:to_i)
				#Note issue order will always be on behalf of opponenet
				PlanetWars.issue_order(source_planet_id , destination_planet_id )
			end
		end
	end

	## sends the order to opponent over the network
	def send_order( source_planet_id , destination_planet_id )
		message = [source_planet_id , destination_planet_id ].join(",")
		@opponenet_machine.puts message
	end

end