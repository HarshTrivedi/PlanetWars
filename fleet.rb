class Fleet

	@app
	attr_accessor :shape ,:owner , :num_ships , :source_planet , :destination_planet , :total_length , :length_left

	def initialize(owner , source_planet , destination_planet , num_ships)

		@owner = owner
		@num_ships = num_ships
		@source_planet = source_planet
		@destination_planet = destination_planet
		@total_length = Math::sqrt((source_planet.shape.left - destination_planet.shape.left)**2 + (source_planet.shape.top - destination_planet.shape.top)**2 ) 

		left = @source_planet.left + @source_planet.radius
		top = @source_planet.top + @source_planet.radius
		radius = 10 # fixed for fleet
		# color is F of owner (owner.color)
		color = green
		@shape = FleetShape.new( @app , left , top , radius , num_ships, color)
		@shape.move(@destination_planet.left , @destination_planet.top)
	end

	# def fly()
	# 	@shape.move()
	# end

	def length_left
		Math::sqrt((left - @destination_planet.left)**2 + (top - @destination_planet.top)**2 ) 
	end


	def left
		@shape.left
	end

	def top
		@shape.top
	end

	def centre
		@shape.left + @shape.radius
	end


end