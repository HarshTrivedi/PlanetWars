require 'Owner.rb'

class FleetShape

	@app
	attr_accessor :circle , :count , :id

	def initialize( app , id , left , top , radius , count , color )
   	     @app = app

   	     @id = id

	     @circle = app.oval(:radius => radius)
	     @circle.left = left
	     @circle.top = top
	     @circle.stroke = nil
	     @circle.fill = nil

	     @count = app.para app.strong(count.to_s) 
	     @count.left = left + radius - 12
	     @count.top = top + radius - 12
	     @count.stroke = eval("@app.#{color}")
	end


	def move( fleet , destination_planet , numships)

		left_destination , top_destination =  destination_planet.center 
		x1 , y1 = center
		horizontal_distance = (left_destination - x1).abs
		vertical_distance = (top_destination - y1).abs

		horizontal_direction = (left_destination - x1 >0 ? 1 : -1 )
		vertical_direction = (top_destination - y1 >0 ? 1 : -1 )

		max_distance = [horizontal_distance , vertical_distance].max

		if horizontal_distance == max_distance
			horizontal_move = 1.0
			vertical_move = vertical_distance.to_f/max_distance.to_f 
		else
			vertical_move = 1.0
			horizontal_move = horizontal_distance.to_f/max_distance.to_f
		end

		pending_vertical_move = 0.0
		pending_horizontal_move = 0.0
		@animate = @app.animate(50) do |frame|

			if pending_vertical_move + vertical_move < 1 
				pending_vertical_move += vertical_move
			else
				@circle.top += vertical_direction * ( 1 )
				@count.top += vertical_direction * ( 1 )
				pending_vertical_move =  vertical_move + pending_vertical_move - 1
			end

			if pending_horizontal_move + horizontal_move < 1 
				pending_horizontal_move += horizontal_move
			else
				@circle.left += horizontal_direction * ( 1 )
				@count.left += horizontal_direction * ( 1 )
				pending_horizontal_move = horizontal_move + pending_horizontal_move - 1
			end

			if vertical_direction * ( center[1] - top_destination ) > 0 or horizontal_direction * ( center[0] - left_destination ) > 0
				@circle.remove
				@count.remove
				@animate.stop
				fleet = Fleet.fleet(fleet.id)
				PlanetWars.remove_fleet(fleet)
				destination_planet.recieve_ships( fleet.owner.id ,numships )
			end
		end
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


class Fleet

	@app
	attr_accessor :shape ,:owner , :num_ships , :source_planet , :destination_planet , :total_length , :length_left , :id

	def initialize(app , id , source_planet , destination_planet , num_ships)
		@app = app
		@id = id
		@owner = Owner.new(source_planet.owner.id)
		@num_ships = num_ships
		@source_planet = source_planet
		@destination_planet = destination_planet
		@total_length = Math::sqrt((source_planet.left - destination_planet.left)**2 + (source_planet.top - destination_planet.top)**2 ) 

		left = @source_planet.left + @source_planet.radius
		top = @source_planet.top + @source_planet.radius
		radius = 10 # fixed for fleet
		# color is F of owner (owner.color)
		color = owner.color

		@source_planet.send_ships( num_ships)
		@shape = FleetShape.new( @app , id , left , top , radius , num_ships, Owner.color(@owner.id) )
		@shape.move( self , @destination_planet , num_ships )
	end

	def length_left
		Math::sqrt((center[1] - @destination_planet.center[1])**2 + (center[0] - @destination_planet.center[0])**2 ) 
	end


	def left
		@shape.circle.left
	end

	def top
		@shape.circle.top
	end

	def center
		[ left + radius , top + radius ]
	end

	def radius
		@shape.circle.width / 2
	end

	def self.fleet(fleet_id)
		PlanetWars.fleet(fleet_id)
	end

end

