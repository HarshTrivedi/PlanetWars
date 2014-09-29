class PlanetWars

	attr_accessor :planets , :fleets

	def initialize

		#load map and plot all maps here

	end

	def num_planet
		@planets.size
	end

	#its index in array would be its ID
	def get_planet(planet_id)
		@planets[planet_id]
	end
	
	def get_planet(planet_id)
		@planets[planet_id]
	end

	# 0 , 1 , 2 are possibilities
	def owning_planets(player_id)
		@planets.select{|x| x.planet_id == player_id}
	end

	def non_owning_planets(player_id)
		@planets.select{|x| x.planet_id != player_id}
	end

	def ememy_planets(player_id)
		@planets.select{|x| x.planet_id != player_id and x.planet_id != 0 }
	end

	def distance(planet1 , planet2)
		return Math::sqrt((planet1.x - planet2.x)**2 + (planet2.y - planet2.y)**2)
	end

	def is_alive?(player_id)
		return true if @planets.select{|x| x.player_id == player_id}.size > 0
		return true if @fleets.select{|x| x.player_id == fleet_id}.size > 0
		return false
	end

	def issue_order(owner , source_planet_id , target_planet_id)
		source_planet = @planets[source_planet_id]
		target_planet = @planets[target_planet_id]
		fleet = Fleet.new()	
		fleet.fly
	end

	def load_map_build_planets

	end

end