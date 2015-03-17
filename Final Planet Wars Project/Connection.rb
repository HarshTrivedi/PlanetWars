class Connection

	def self.connection=(connection)
		@@connection = connection
	end

	def self.connection
		@@connection
	end

	
	def self.listen_to_opponent
		@@connection.listen_to_opponent
	end

	def self.send_order( source_planet_id , destination_planet_id )
		@@connection.send_order( source_planet_id , destination_planet_id )
	end

end
