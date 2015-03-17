require 'Owner.rb'
require 'Connection.rb'
require 'FilePath.rb'
require 'Audio.rb'

class PlanetShape

	@app
	attr_accessor :circle , :image ,:count

	def initialize( app , left , top , radius , count , color )
	     @app = app
	     @circle = app.oval(:radius => radius )
	     @circle.left = left 
	     @circle.top = top

	     @image = @app.image FilePath.planet_image(color) , :left => left , :top => top , :width => 2*radius

	     @circle.hover do
	     	@circle.stroke = @app.white 	if get_planet != PlanetWars.source_planet and get_planet != PlanetWars.destination_planet
	     end

	     @circle.leave do
	     	if get_planet != PlanetWars.source_planet and get_planet != PlanetWars.destination_planet
	     		@circle.stroke = @app.black
	     	end
	     end

	     @circle.click do
	     	if PlanetWars.select_mode
				if PlanetWars.source_planet.nil?
					if get_planet.owner.id == PlanetWars.player_id
						@circle.stroke = @app.brown	
						PlanetWars.source_planet = get_planet
					end
				else
					if PlanetWars.source_planet != get_planet
						Audio.play("launch")
						@circle.stroke = @app.brown	
						PlanetWars.destination_planet = get_planet
						num_ships = ( ( PlanetWars.source_planet.num_ships + 1 ) / 2 ).ceil
						fleet = Fleet.new( @app , PlanetWars.get_next_fleet_id , PlanetWars.source_planet , PlanetWars.destination_planet , num_ships)
						PlanetWars.add_fleet(fleet)
						PlanetWars.select_mode = false   
						PlanetWars.source_planet.shape.circle.stroke = @app.black
						PlanetWars.destination_planet.shape.circle.stroke = @app.black

						if PlanetWars.playing_mode == PlanetWars::MULTI_PLAYER
							#send this order On to the opponenet
							Connection.send_order( PlanetWars.source_planet.id , PlanetWars.destination_planet.id )
						end

						PlanetWars.source_planet = nil
						PlanetWars.destination_planet = nil  		
					end

				end
	     	end
	     end

	     @count = app.para count.to_s 
	     @count.left = left + radius - 12
	     @count.top = top + radius - 12
	     @count.stroke = app.yellow
	end

	def get_planet

		for planet in PlanetWars.planets
			return planet if planet.center == center
		end
		return nil
	end

	def change_color(color)
		@image.path = FilePath.planet_image(color)
	end

	def change_count(count)
		@count.text = count.to_s
		@count.stroke = @app.yellow
		#adjust center if number of digits have changed.
	end

	def left
		@circle.left
	end

	def top
		@circle.top
	end

	def radius
		@circle.width / 2
	end

	def center
		[ left + radius , top + radius ]
	end


end

class Planet

	@app
	attr_accessor :shape ,:id , :owner , :growth_rate #, :left , :top , :radius

	def initialize( app ,  planet_id , owner , num_ships , growth_rate , left , top)
		@app = app
		@id = planet_id
		@owner = owner
		@num_ships = num_ships
		@growth_rate = growth_rate
		@left = left
		@top = top
		# radius = F of growth rate  
		radius = (3 * growth_rate + 15 ) # for now
		@radius = radius
		# color = F of owner (ie: color = owner.color)  
		# color = green # for now
		@shape = PlanetShape.new( @app , left , top , radius , num_ships , owner.color )

	end

	def num_ships
		@shape.count.text.to_i
	end

	def left
		@shape.circle.left
	end

	def top
		@shape.circle.top
	end

	def radius
		@shape.circle.width / 2
	end

	def center
		[ left + radius , top + radius ]
	end

	def change_owner_to(owner_id)
		start_growing if @owner.id == 0 and owner_id != 0
		@owner.id = owner_id
		@shape.change_color( Owner.color(owner_id) )
		Audio.play("explode")
	end
	
	def send_ships(count)

		present_ships = @shape.count.text.strip.to_i
		ships_to_be_added =  - count
		if present_ships + ships_to_be_added >= 0
			@shape.count.text = ( present_ships + ships_to_be_added ).to_s
		else
			@shape.count.text = "0"
		end

	end

	def recieve_ships(fleet_owner_id , count)
		present_ships = @shape.count.text.strip.to_i
		if @owner.id == fleet_owner_id
			ships_to_be_added = count
			@shape.count.text = ( present_ships + ships_to_be_added ).to_s
		else
			ships_to_be_added =  - count

			if present_ships + ships_to_be_added >= 0
				@shape.count.text = ( present_ships + ships_to_be_added ).to_s
			else
				@shape.count.text = ( present_ships + ships_to_be_added ).abs.to_s
				change_owner_to( fleet_owner_id )
			end			
		end

		winner = PlanetWars.game_over?

		if winner != 0
			if PlanetWars.player_id == winner
				@app.visit("/game_over/#{PlanetWars.player_name }")
			else
				@app.visit("/game_over/#{PlanetWars.opponent_name}")
			end
		end

	end


	def grow_ships(count)

		present_ships = @shape.count.text.strip.to_i
		ships_to_be_added = count
		@shape.count.text = ( present_ships + ships_to_be_added ).to_s

	end

	# call this when , planets become non neutral
	def start_growing
		# grow ships according to its growth rate
		# to be implemented
		@app.animate(1) do |frame|
			grow_ships(@growth_rate)
		end
	end	

	def glow
		@shape.circle.stroke = @app.white
	end

end