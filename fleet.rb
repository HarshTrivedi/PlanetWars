class Fleet
	attr_accessor :shape ,:owner , :num_ships , :source_planet , :destination_planet , :total_length , :length_left
	def initialize(owner , source_planet , destination_planet , num_ships)
		@owner = owner
		@num_ships = num_ships
		@source_planet = source_planet
		@destination_planet = destination_planet
		@total_length = Math::sqrt((source_planet.shape.x - destination_planet.shape.x)**2 + (source_planet.shape.y - destination_planet.shape.y)**2 ) 


	end

	def fly
		@shape = oval(top:  , left:  , radius: 10)
		##Do all the animation here# animate the 'shape'
	end

	def length_left
		Math::sqrt((shape.x - destination_planet.shape.x)**2 + (shape.y - destination_planet.shape.y)**2 ) 
	end

end