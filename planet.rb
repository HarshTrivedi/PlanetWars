class Planet
	attr_accessor :shape ,:planet_id , :owner , :num_ships , :growth_rate 

	def initialize(planet_id , owner , num_ships , growth_rate , x , y)
		@planet_id = planet_id
		@owner = owner
		@num_ships = num_ships
		@growth_rate = growth_rate
	end

end