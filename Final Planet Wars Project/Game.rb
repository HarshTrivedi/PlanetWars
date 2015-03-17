#!/home/harsh/.shoes/federales/shoes

require 'Storage.rb'
require 'PlanetWars.rb'
require 'InternalClient.rb'
require 'InternalServer.rb'

class Game < Shoes

	url '/' , :index
	url '/single_player/start_game', :start_single_player
	url '/multi_player/start_game/([^/]*)/([^/]*)', :start_multi_player
	url '/multi_player/select_opponent' , :select_opponent
	url '/game_over/([^/]*)' , :game_over
	url '/about' , :about
	url '/options' , :options
	url '/controls' , :controls
	url '/choose_map' , :choose_map
	url '/choose_bot' , :choose_bot

	def index
		# visit('/choose_map')
		keypress do |k|
			if k == "control_q".to_sym
				yes = confirm("Are you sure you want to Leave this game?")
				if yes
					MainClient.unregister_as_online if MainClient.initialized?
					exit 
				end
			end	
		end
		background FilePath.background_image_home , :width => 1100 , :height => 700
		stack :margin => 80 , :align => "center" do
			banner "Planet WARS" , :stroke => white , :align => "left" , :margin_left => 20 , :margin_bottom => 50 , :margin_top => 50		
			button "Single Player Game" , :align => "center" , :width => "45%" , :margin => 10 do
				visit('/choose_map')
			end
			button "Multi Player Game" , :align => "center" , :width => "45%" , :margin => 10  do
					main_server_ip , main_server_port = Storage.main_server_ip , Storage.main_server_port 
					if Storage.main_server_ip.nil? or Storage.main_server_port.nil? or Address.open?(Storage.main_server_ip , Storage.main_server_port)
						begin
							main_server_address = ask("Enter Main Server address as: 'IP:PORT'")												
						end while ( main_server_address.chomp =~ /(^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5])))|(localhost):(\d.*)/  ).nil?
						main_server_ip , main_server_port = main_server_address.split(':')[0] , main_server_address.split(':')[1].to_i 
						Storage.main_server_ip = main_server_ip
						Storage.main_server_port = main_server_port
					end
					if not Address.open?( main_server_ip , main_server_port)
						MainClient.initialize(main_server_ip , main_server_port)
						username = Storage.username
		     			while username.nil?
							username = ask("I guess you are playing first time. Please Enter your name:")
							valid = MainClient.register_username(username)					
							break if valid
						end
						Storage.username = username	
						MainClient.register_as_online(username) #this should be implicitly done by STEP:0 if username was already there(code server this way): TODOS later
						visit('/multi_player/select_opponent')
					else
						alert("Sorry, but not able to reach main server. Try again later.")
					end
			end
			button "About" , :align => "center" , :width => "45%" , :margin => 10  do

			end
			button "Options" , :align => "center" , :width => "45%" , :margin => 10  do
				
			end
			button "Controls" , :align => "center" , :width => "45%" , :margin => 10  do
				
			end
			button "Exit" , :align => "center" , :width => "45%" , :margin => 10  do
					MainClient.unregister_as_online if MainClient.initialized?
					yes = confirm("Are you sure you want to Leave this game?")
					exit if yes
			end
		end
	end



	def start_single_player		
			strokewidth 3
			keypress do |k|
					PlanetWars.select_mode = true if k == "s"
					if k == "escape".to_sym
						PlanetWars.source_planet.shape.circle.stroke = black if not PlanetWars.source_planet.nil?
						PlanetWars.destination_planet.shape.circle.stroke = black  if not PlanetWars.destination_planet.nil?
						PlanetWars.source_planet = nil
						PlanetWars.destination_planet = nil
						PlanetWars.select_mode = false 
					end
					if k == "control_q".to_sym
						yes = confirm("Are you sure you want to Leave this game?")
						if yes
							MainClient.unregister_as_online if MainClient.initialized?
							exit
						end
					end	
			end
			PlanetWars.player_id = 1 # clicking will issue order
			PlanetWars.opponent_id = 2 # either BOT (single player) or Socket Program (multiplayer) opponenet will issue order
			PlanetWars.player_name = "You"
			PlanetWars.opponent_name = "Machine"
			PlanetWars.initialize(self , PlanetWars::SINGLE_PLAYER )
		   	# PlanetWars.start_bot
	end		


	def select_opponent
			keypress do |k|
					if k == "control_q".to_sym
						yes = confirm("Are you sure you want to Leave this game?")
						if yes
							MainClient.unregister_as_online if MainClient.initialized?
							exit
						end
					end	
			end
			#STEP3: render these client_usernames with corresponding REQUEST buttons on their side.
			#STEP 2: Main Server should give in response, which clients are currently online.
			#TODO prompt to wait here for a white until the data get loaded
			online_client_usernames = MainClient.online_clients
			#TODO LATER: Exclusively keep one thread in this client to subscribe to Main Server. If any new client leaves or enters, information will be given on this socket					

			background FilePath.background_image_options , :width => 1100 , :height => 700

			back = image FilePath.back_button_image , :left => 30 , :top => "50%" , :width => 40
			back.click{} 
			back.release do	
				MainClient.terminate_listening_thread 
				MainClient.unregister_as_online
				visit('/') 
			end
			stack :margin => 30 do
				para "Online Players:" , :stroke => white 
				flow do
					selected_client = online_client_usernames.first
				    @list = list_box items: online_client_usernames , width: "70%" , choose: online_client_usernames.first do |list|
				    	selected_client = list.text
				    end
				    #STEP4 send request to play to the selected client, when client presses submit button
				    button "Request to Play" , :width => "30%" ,:margin_left => 30 , :margin_right => 30 do	
				    	if not selected_client.nil?
					    	MainClient.play_request(selected_client) 
					    else
					    	alert "Selection cant be blank."
					    end
				    end
				    #STEP5
				    # MainClient.listen_to_main_server(Shoes.APPS[0].app)
					MainClient.listen_to_main_server(self , @list)			
		
					#When this window is open, either of 2 things can occur:
						#1-> User requests some other client to play, and he accepts the request 
						# Get the opponents IP and start game as SERVER (player id 1)
						#2-> User gets some one else's request and has option either to accept or reject.
						#If reject, send back "rejected" answer to original requester, nothing else happens
						#If accepts, send back "accepted" answer and start the game as CLIENT (player_id 2).
				end
			end
	end


	def start_multi_player(address , as_server)
		ip = address.split(':')[0]
		port = address.split(':')[1]
		Shoes.debug "IP is #{ip}"
		Shoes.debug "Port is #{port}"
		port = port.to_i
		strokewidth 3
		keypress do |k|
			PlanetWars.select_mode = true if k == "s"
			if k == "escape".to_sym
				PlanetWars.source_planet.shape.circle.stroke = black if not PlanetWars.source_planet.nil?
				PlanetWars.destination_planet.shape.circle.stroke = black  if not PlanetWars.destination_planet.nil?
				PlanetWars.source_planet = nil
				PlanetWars.destination_planet = nil
				PlanetWars.select_mode = false 
			end
			if k == "control_q".to_sym
				yes = confirm("Are you sure you want to Leave this game? The opponent will be declared the Winner.")
				if yes
					MainClient.unregister_as_online if MainClient.initialized?
					MainClient.abrupt_quit_message
					exit 
				end
			end	
		end
		PlanetWars.map = 1
		## Give option to choose map to the player who acts as server TODO
		if as_server == "true"
				PlanetWars.player_id = 1
				PlanetWars.opponent_id = 2
				InternalServer.new(ip , port)
				PlanetWars.initialize(self , PlanetWars::MULTI_PLAYER)				
				Connection.listen_to_opponent
		else
				PlanetWars.player_id = 2
				PlanetWars.opponent_id = 1
				InternalClient.new(ip , port)
				PlanetWars.initialize(self , PlanetWars::MULTI_PLAYER)				
				Connection.listen_to_opponent
		end
	end

	def game_over(winner_name)

		background FilePath.background_image_gameover , :width => 1100 , :height => 700
		stack :margin => 80 , :align => "center" do
			banner "#{winner_name} Wins" , :stroke => white , :align => "center" , :margin => 50
			button "Main Menu" , :align => "center" , :width => "100%" , :margin => 10  do
				visit('/')
			end
			button "Single Player Game" , :align => "center" , :width => "100%%" , :margin => 10  do
				visit('/choose_map')
			end
			button "Multi Player Game" , :align => "center" , :width => "100%%" , :margin => 10  do
					if Storage.main_server_ip.nil? or Storage.main_server_port.nil? or not Address.open?(Storage.main_server_ip , Storage.main_server_port)
						begin
							main_server_address = ask("Enter Main Server address as: 'IP:PORT'")												
							Shoes.debug ( main_server_address.chomp =~ /(^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5])))|(localhost):(\d.*)/  ).nil?
						end while ( main_server_address.chomp =~ /(^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5])))|(localhost):(\d.*)/  ).nil?
						main_server_ip , main_server_port = main_server_address.split(':')[0] , main_server_address.split(':')[1].to_i 
						Storage.main_server_ip = main_server_ip
						Storage.main_server_port = main_server_port
					end
					if not Address.open?( main_server_ip , main_server_port)
						MainClient.initialize(main_server_ip , main_server_port)
						username = Storage.username
		     			while username.nil?
							username = ask("I guess you are playing first time. Please Enter your name:")
							valid = MainClient.register_username(username)					
							break if valid
						end
						Storage.username = username	
						MainClient.register_as_online(username) #this should be implicitly done by STEP:0 if username was already there(code server this way): TODOS later
						visit('/multi_player/select_opponent')
					else
						alert("Sorry, but not able to reach main server. Try again later.")
					end
			end
			button "Exit" , :align => "center" , :width => "100%" , :margin => 10  do
					MainClient.unregister_as_online if MainClient.initialized?
					yes = confirm("Are you sure you want to Leave this game?")
					exit if yes
			end
		end
	end

	def choose_map

		strokewidth 3
		background FilePath.background_image_options , :width => 1100 , :height => 700
		banner "Choose Map" , :stroke => white , :align => "center" , :margin => "5%" , :height => "10%" 
		back = image FilePath.back_button_image , :left => 30 , :top => "50%" , :width => 40
		back.click{} 
		back.release { visit('/') }
		stack :margin => 70 , :align => "center" , :height => "80%" , :width => "100%" do
			flow :align => "center" , :height => "100%" do
				map1 = image FilePath.galaxy_image(1)  , :align => "center" , :width => "50%" , :height => "90%" , :margin => "5%"
				map2 = image FilePath.galaxy_image(2)  , :align => "center" , :width => "50%" , :height => "90%" , :margin => "5%" 
				map1.hover { map1.width += 10 ; map1.height += 10 ; map2.width -= 10 ; map2.height -= 10 }
				map2.hover { map2.width += 10 ; map2.height += 10 ; map1.width -= 10 ; map1.height -= 10}
				map1.leave { map1.width -= 10 ; map1.height -= 10 ; map2.width += 10 ; map2.height += 10}
				map2.leave { map2.width -= 10 ; map2.height -= 10 ; map1.width += 10 ; map1.height += 10}
				map1.click {}
				map2.click {}
				map1.release do
					PlanetWars.map = 1
					visit('/choose_bot')
				end
				map2.release do
					PlanetWars.map = 2
					visit('/choose_bot') 
				end
			end
		end
	end

	def choose_bot
		background FilePath.background_image_options , :width => 1100 , :height => 700
		banner "Choose Opponent Bot" , :stroke => white , :align => "center" , :margin => "5%" , :height => "10%" 
		back = image FilePath.back_button_image , :left => 30 , :top => "50%" , :width => 40
		back.click{} 
		back.release { visit('/choose_map') }
		stack :margin => 70 , :align => "center" , :height => "80%" , :width => "100%" do
			flow :align => "center" , :height => "100%" do
				bot1 = button "Simple Bot"  , :align => "center" , :width => "50%" , :height => "90%" , :margin => "5%"
				bot2 = button "Dual Bot"  , :align => "center" , :width => "50%" , :height => "90%" , :margin => "5%" 
				bot1.click do
					PlanetWars.bot = 1
					visit('/single_player/start_game')
				end
				bot2.click do
					PlanetWars.bot = 2
					visit('/single_player/start_game')
				end

			end
		end
	end


end


Shoes.app :width => 1100 , :height => 700 , :resizable => false
