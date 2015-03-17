require 'FilePath.rb'
require 'Planet.rb'
require 'Fleet.rb'
require 'MainClient.rb'

class PlanetWars
	@app

	# @@fleet , @@planets

	SINGLE_PLAYER = 10
	MULTI_PLAYER = 20

	def self.initialize(app , playing_mode )
		@app = app
		@app.image FilePath.galaxy_image(map) , :width => 1100 , :height => 700
		back = @app.image FilePath.back_button_image , :left => 20 , :top => 20 , :width => 30
		back.click{} 
		back.release do	
			if PlanetWars.playing_mode == PlanetWars::MULTI_PLAYER
				yes = @app.confirm "Are you sure you want to Leave this game? The opponent will be declared the Winner."
			else
				yes = @app.confirm "Are you sure you want to Leave this game?"
			end
			if yes
				if PlanetWars.playing_mode == PlanetWars::MULTI_PLAYER
					MainClient.terminate_listening_thread 
					MainClient.unregister_as_online
					MainClient.abrupt_quit_message
				end
				@app.visit('/') 
			end
		end		

		file = File.open("/home/harsh/PlanetWarsRuby/testing/map#{map}.txt" , "r") 
		@@planets = []
		@@fleets = []
		i = 0
		file.each_line do |line|
			array = line.split(" ")
			left , top = array[1].to_i * 40 + 60 , array[2].to_i * 25 + 30
			owner = Owner.new(array[3].to_i)
			numships = array[4].to_i
			growth_rate = array[5].to_i
			planet = Planet.new( app ,  i , owner , numships , growth_rate , left , top)
			@@planets << planet
			i += 1
		end
		file.close
		@@planets[1].start_growing
		@@planets[PlanetWars.player_id].glow
		@@planets[2].start_growing
		@@source_planet = nil
		@@destination_planet = nil
		@@select_mode = false
		@@last_fleet_id_assigned = 0
		@@playing_mode = playing_mode


		if playing_mode == SINGLE_PLAYER
			start_bot
		end

	end

	# def self.register_on_server
	# 	@@server.puts "WRONG"
	# end

	def self.playing_mode
		@@playing_mode
	end

	def self.playing_mode=(playing_mode)
		@@playing_mode = playing_mode
	end

	def self.player_id
		@@player_id
	end

	def self.player_id=(player_id)
		@@player_id = player_id
	end

	def self.opponent_id
		@@opponent_id
	end

	def self.opponent_id=(opponent_id)
		@@opponent_id = opponent_id
	end

	def self.fleet(fleet_id)
		@@fleets.select{|fleet| fleet.id == fleet_id }[0] rescue nil
	end


	def self.last_fleet_id_assigned
		@@last_fleet_id_assigned
	end

	def self.get_next_fleet_id
		@@last_fleet_id_assigned += 1
		@@last_fleet_id_assigned
	end

	def self.planets
		@@planets
	end

	def self.fleets
		@@fleets
	end

	def self.source_planet
		@@source_planet
	end

	def self.source_planet=(planet)
		@@source_planet = planet
	end

	def self.destination_planet
		@@destination_planet
	end

	def self.destination_planet=(planet)
		@@destination_planet = planet
	end

	def self.select_mode
		@@select_mode
	end

	def self.select_mode=(select_mode)
		@@select_mode = select_mode
	end

	def self.add_fleet(fleet)
		@@fleets << fleet
	end

	def self.remove_fleet(fleet)
		@@fleets.delete(fleet)
	end

	def self.num_planet
		@@planets.size
	end

	#its index in array would be its ID
	def self.planet(planet_id)
		@@planets[planet_id]
	end
	
	# 0 , 1 , 2 are possibilities
	def self.owning_planets(player_id)
		@@planets.select{|planet| planet.owner.id == player_id} 
	end

	def self.non_owning_planets(player_id)
		@@planets.select{|planet| planet.owner.id != player_id}
	end

	def self.ememy_planets(player_id)
		@@planets.select{|planet| planet.owner.id != player_id and planet.owner.id != 0 }
	end

	def self.owning_fleets(player_id)
		@@fleets.select{|fleet| fleet.owner.id == player_id} 
	end

	def self.ememy_fleets(player_id)
		@@fleets.select{|fleet| fleet.owner.id != player_id and planet.owner.id != 0 }
	end

	def self.distance(planet1 , planet2)
		return Math::sqrt((planet1.center[0] - planet2.center[0])**2 + (planet1.center[1] - planet2.center[1])**2)
	end

	def self.bot=(bot)
		@@bot = bot
	end

	def self.bot
		@@bot
	end

	def self.map
		@@map
	end

	def self.map=(map)
		@@map=map
	end

	def self.is_alive?(player_id)
		return true if	owning_planets(player_id).size > 0
		return true	if  owning_fleets(player_id).size > 0
		return false
	end

	def self.game_over?
		if not is_alive?(1) or not is_alive?(2)
			return 1 if is_alive?(1)
			return 2 if is_alive?(2)
		end
		return 0
	end

	def self.issue_order( source_planet_id , target_planet_id)
		source_planet = PlanetWars.planets[source_planet_id]
		destination_planet = PlanetWars.planets[target_planet_id]
		num_ships = ( ( source_planet.num_ships + 1 ) / 2 ).ceil
		# alert PlanetWars.get_next_fleet_id
		fleet = Fleet.new( @app , PlanetWars.get_next_fleet_id ,  source_planet , destination_planet , num_ships)
		@@fleets << fleet
	end


	def self.bot1
		# use issue_order on behalf of opponenet (single player)
		@every = @app.every(1) do
			#if we dont have any fleet on flight:
			if( PlanetWars.owning_fleets(PlanetWars.opponent_id).size == 0)
				#find our strongest planet and make it source
				source_planet = PlanetWars.owning_planets(PlanetWars.opponent_id).max_by{|x| x.num_ships}
				#find the weakest planet and make it destination
				destination_planet = (PlanetWars.owning_planets(PlanetWars.player_id) +  PlanetWars.owning_planets(0) ).min_by{|x| x.num_ships}
				issue_order(  source_planet.id , destination_planet.id )
			end
		end

	end

	def self.bot2
		# use issue_order on behalf of opponenet (single player)
		@every = @app.every(1) do
			#if we dont have any fleet on flight:
			if( PlanetWars.owning_fleets(PlanetWars.opponent_id).size < 4)
				#find our strongest planet and make it source
				source_planet = PlanetWars.owning_planets(PlanetWars.opponent_id).max_by{|x| x.num_ships}
				#find the weakest planet and make it destination
				destination_planet = (PlanetWars.owning_planets(PlanetWars.player_id) +  PlanetWars.owning_planets(0) ).min_by{|x| distance(x , source_planet)}
				issue_order(  source_planet.id , destination_planet.id )
			end
		end

	end

	def self.reset_game
		##To be Implemented
	end


	def self.player_name
		@@player_name
	end

	def self.player_name=(player_name)
		@@player_name = player_name
	end

	def self.opponent_name
		@@opponent_name 
	end

	def self.opponent_name=(player_name)
		@@opponent_name = player_name
	end

	def self.start_bot
		if @@bot == 1
			bot1
		else
			bot2
		end
	end

end