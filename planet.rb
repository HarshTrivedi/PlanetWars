class Planet

	@app
	attr_accessor :shape ,:planet_id , :owner , :num_ships , :growth_rate 

	def initialize( @app ,  planet_id , owner , num_ships , growth_rate , left , top)
		@planet_id = planet_id
		@owner = owner
		@num_ships = num_ships
		@growth_rate = growth_rate
		# radius = F of growth rate  
		radius = growth_rate # for now
		# color = F of owner (ie: color = owner.color)  
		color = green # for now
		@shape = PlanetShape.new( @app , left , top , radius , num_ships , color )

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