require "socket"
require 'json'
class Server
  def initialize( ip  , port )
    @server = TCPServer.open( ip, port )
    @clients = {}
    run
  end
 
  def run
    loop {
      Thread.start(@server.accept) do | client |
      		puts "A CONNECTION REQUEST HAS COME"
	 		listen_user_messages( client )
      end
    }.join
  end
 
  def listen_user_messages(client )
  	  loop do
	      message = client.gets.chomp
	      puts message
	      hash = JSON.parse(message)
	      puts hash
	      username = hash["username"]
	      method = hash["method"]    
	      puts username
	      puts method
	      
	      return_string = register_username(username , client , hash) if method == "register_username"
	      return_string = register_as_online(username , client , hash) if method == "register_as_online"
	      return_string = unregister_as_online(username , client , hash) if method == "unregister_as_online"
	      return_string = online_clients(username , client , hash) if method == "online_clients"
	      return_string = play_request(username , client , hash) if method == "play_request"
	      return_string = response_to_request(username , client , hash) if method == "response_to_request"
	      return_string = abrupt_quit_message(username , client , hash) if method == "abrupt_quit_message"

	      puts "TO BE RETURNED : #{return_string}"
	      client.puts return_string if not return_string.nil?
	  end
  end

  def register_username(username , client , hash)
  		puts "#{username} has tried to register : #{client}"
  		puts "List of all clients : #{@clients}"
  		if @clients.keys.select{|x| x == username}.size == 0
  			@clients["#{username}"] = client
        hash = {:method => "new_online_user" , :username => username}
        message = hash.to_json
        all_other_clients = (@clients.values - [client])
        all_other_clients.each{|client| client.puts message rescue nil}
  			return {:username => username , :method => "register_username" , :success => true}.to_json
  		end
		return {:username => username , :method => "register_username" , :success => false}.to_json
  end

  def register_as_online(username , client , hash)
  		puts "#{username} has tried to register : #{client}"
  		puts "List of all clients : #{@clients}"
  		if @clients.keys.select{|x| x == username}.size == 0
  			@clients["#{username}"] = client
	        # Also send this information that new client has arrived to all clients
	        hash = {:method => "new_online_user" , :username => username}
	        message = hash.to_json
	        all_other_clients = (@clients.values - [client])
	        all_other_clients.each{|client| client.puts message rescue nil}
  		end
        return nil
  end

 def unregister_as_online(username , client , hash)
  		puts "#{username} has tried to register : #{client}"
  		puts "List of all clients : #{@clients}"
  		if @clients.keys.select{|x| x == username}.size > 0
  			@clients.delete(username)
	        hash = {:method => "remove_online_user" , :username => username}
	        message = hash.to_json
	        all_other_clients = (@clients.values - [client])
	        all_other_clients.each{|client| client.puts message rescue nil}
  		end
  		return nil
  end

  def online_clients(username , client , hash)
  		puts "#{username} wants list of all on clients"
  		puts "List of all clients : #{@clients}"
  		return  {:username => username , :method => "online_clients" , :online_client_usernames => @clients.keys ,:success => true}.to_json
  end

  def play_request(username , client , hash)
  		puts "#{username} wants to play with #{hash["opponent_username"]}"
  		puts "List of all clients : #{@clients}"
  		opponent_username = hash["opponent_username"]
  		opponent_client = @clients["#{opponent_username}"]
  		# client.addr 		#["AF_INET", 3000, "127.0.0.1", "127.0.0.1"]
		  # client.peeraddr 	#["AF_INET", 42518, "127.0.0.1", "127.0.0.1"]
		# TODO: check which one of the above should be taken....NONE actually 
  		message = {:username => username , :method => "play_request" }.to_json
  		puts "opponent_client is #{opponent_client}   with username  #{opponent_username}"
  		puts message
  		opponent_client.puts message
  		return nil
  end

  def response_to_request(username , client , hash)
  		puts " Response to request :#{username}  #{client}"
  		puts "List of all clients : #{@clients}"
  		username = hash["username"]
  		opponent_username = hash["opponent_username"]
  		opponent_client = @clients["#{opponent_username}"]
  		response = hash["accept"]
  		if response == false
  			puts "-ve response to be given"
  			message = {:username => username , :method => "response_to_request" , :accept => false}.to_json
  			opponent_client.puts message
  		else
  			puts "+ve response to be given"
        address = hash["address"]
  			# puts client.addr 		#["AF_INET", 3000, "127.0.0.1", "127.0.0.1"]
  			# puts client.peeraddr 	#["AF_INET", 42518, "127.0.0.1", "127.0.0.1"]
  			# TODO: check which one of the above should be taken....
  			message = {:username => username , :method => "response_to_request" , :accept => true , :address => address }.to_json
  			puts "#{message}   #{client}"
  			opponent_client.puts message
  		end
  		return nil
  end

  def abrupt_quit_message(username , client , hash)
  		opponent_username = hash["opponent_username"]
  		opponent_client = @clients["#{opponent_username}"]
  		puts "Into abroupt quit method..  #{opponent_username}   ... #{username}"
  		message = {:username => username , :method => "abrupt_quit_message" }.to_json
  		opponent_client.puts message
  		puts "message sent"
  		return nil
  end


end
 
local_ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
puts "Server started at -> #{local_ip}:4000"
#local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}

Server.new( local_ip , 4000 )
