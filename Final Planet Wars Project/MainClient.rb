require 'Address.rb'

require 'net/http'
require 'json'
require 'open-uri'

class MainClient
	## if this app acts as client, its player_id should be set 2 , and opponenet_id must be set 2
	@@server = nil
	def self.initialize( ip , port)
	    @@server = TCPSocket.open( ip, port )
	end

	def self.initialized?
		not @@server.nil?
	end

	def self.listen_to_main_server(app , list)
		@@thread = Thread.new do
			sleep 0.5
			loop do
				# app.alert("Hurray! :)")
				message_string = @@server.gets.chomp
				app.timer(0.5) do
				hash = JSON.parse(message_string)
				if hash["method"] == "play_request"
					##FILL THIS UP (STEP5 see down)
					# ask want to join (Accept or Decline?)
					play = app.confirm("A request to play has been made to you by #{hash["username"]}. Want to start game?")
					if play
					    #username is of the person who has requested me to play
						opponent_username = hash["username"]
						ip = Address.local_ip
						port = Address.open_port(ip)
						address = "#{ip}:#{port}"
						hash = { :username => @@username , :opponent_username => opponent_username , :address => address , :method => "response_to_request" , :accept => true  }
						send_to_main_server(hash.to_json)
						PlanetWars.player_name = @@username
						PlanetWars.opponent_name = opponent_username
						Shoes.debug "player is #{PlanetWars.player_name}  Opponent is #{PlanetWars.opponent_name}"
						app.visit("/multi_player/start_game/#{ip}:#{port}/true")
					else
						hash = { :username => @@username , :opponent_username => hash["username"] , :method => "response_to_request" , :accept => false }
						send_to_main_server(hash.to_json)
					end
				elsif hash["method"] == "response_to_request"
					##FILL THIS UP (STEP5 see down)
					if hash["accept"] == true
						# app.alert("#{hash["username"]} has accepted your request. Click OK to start the game")
						# puts "#{hash["username"]} has accepted your request to play. (lets start)"
						# start the Game here...
						# Visit the multiplayer URL here.
						address = hash["address"]
						ip = address.split[0]
						port = address.split[1]
						opponent_username = hash["username"]
						# app.alert "In here #{address} "
						PlanetWars.player_name = @@username
						PlanetWars.opponent_name = opponent_username
						Shoes.debug "player is #{PlanetWars.player_name}  Opponent is #{PlanetWars.opponent_name}"
						app.visit("/multi_player/start_game/#{ip}:#{port}/false")
					else
						app.alert "#{hash["username"]} has rejected your request. Sorry, Cant Help."
					end
				elsif hash["method"] ==  "new_online_user"
						username_added = hash["username"]
						if app.app.location == "/multi_player/select_opponent"							
							app.app do
								list.items = list.items + [username_added]
								list.choose(username_added) if list.text.nil? or list.text.empty?
							end
						end
				elsif hash["method"] ==  "remove_online_user"
						username_removed = hash["username"]
						if app.app.location == "/multi_player/select_opponent"							
							app.app do
								list.items = list.items - [username_removed]
								list.choose(list.items.sample) if list.text.nil? or list.text.empty?
							end
						end
				elsif hash["method"] == "abrupt_quit_message"
						Shoes.debug "In here #{app.app.location}"
						if app.app.location =~ /\/multi_player\/start_game\/.*/
							app.alert "#{PlanetWars.opponent_name} has abruptly left the game. You Win"
							app.visit("/game_over/#{PlanetWars.player_name}")
						end
				end
				end
			end
			
		end
	end

	def self.terminate_listening_thread
		@@thread.kill
	end

	def self.listening_thread_status
		@@thread.status
	end

	def self.send_to_main_server( message_string)		
		@@server.puts message_string
	end

	def self.register_username(username)
		hash = {:username => username , :method => "register_username"}
		send_to_main_server(hash.to_json)
		response = @@server.gets.chomp
		response_hash = JSON.parse(response) rescue {}
		Shoes.debug response_hash
		if not response_hash.nil? and response_hash["method"] == "register_username" and response_hash["success"] == true and not username.empty?
			@@username = username
			return true 
		end
		return false
		##IMP NOTE : Dont forget to close socket connection at server end
	end

	def self.register_as_online(username)
		hash = {:username => username , :method => "register_as_online"}
		send_to_main_server(hash.to_json)
		@@username = username
		##IMP NOTE : Dont forget to close socket connection at server end
	end

	def self.unregister_as_online
		hash = {:username => @@username , :method => "unregister_as_online"}
		send_to_main_server(hash.to_json)
		##IMP NOTE : Dont forget to close socket connection at server end
	end

	def self.online_clients
		hash = {:username => @@username , :method => "online_clients"}
		send_to_main_server(hash.to_json)
		response = @@server.gets.chomp
		response_hash = JSON.parse(response)
		Shoes.warn response_hash
		if not response_hash.nil? and  response_hash["method"] == "online_clients" and response_hash["success"] == true
			Shoes.warn response_hash["online_client_usernames"] - [@@username]
			return response_hash["online_client_usernames"] - [@@username]
		end
		return nil
		##IMP NOTE : Dont forget to close socket connection at server end
	end

	def self.abrupt_quit_message
		hash = {:username => @@username , :opponent_username => PlanetWars.opponent_name , :method => "abrupt_quit_message"}
		send_to_main_server(hash.to_json)
		return nil
	end

	def self.play_request(opponent_username)
		username = @@username
		opponenet_username = opponent_username
		hash = {:username => username , :opponent_username => opponent_username ,:method => "play_request" }
		message = hash.to_json
		send_to_main_server(message)
		Shoes.debug "sent play request to #{opponent_username}"
	end


end