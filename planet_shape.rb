require 'green_shoes'

class PlanetShape

	@app
	attr_accessor :planet , :count

	def initialize( app , left , top , radius , count , color )
	     @app = app
	     @planet = app.oval left, top , radius, fill: color
	     @count = app.para count.to_s , left: left + radius - 9 , top: top + radius - 9 , stroke: app.yellow
	end

	def change_color(color)
		@planet.fill = color
	end

	# planets dont move... shift this method for fleets.
	def move( left_destination , top_destination)
		x1 = @planet.left + @planet.radius
		y1 = @planet.top + @planet.radius
		horizontal_distance = (left_destination - x1).abs
		vertical_distance = (top_destination - y1).abs
		horizontal_direction = (left_destination - x1 >0 ? 1 : -1 )
		vertical_direction = (top_destination - y1 >0 ? 1 : -1 )

		max_distance = [horizontal_distance , vertical_distance].max

		if horizontal_distance = max_distance
			horizontal_move = 1
			vertical_move = vertical_distance/max_distance
		else
			vertical_move = 1
			horizontal_move = horizontal_distance/max_distance
		end

		@animate = @app.animate(30) do |frame|
			@planet.top += vertical_direction * vertical_move
			@planet.left += horizontal_direction * horizontal_move
			@count.top += vertical_direction * vertical_move
			@count.left += horizontal_direction * horizontal_move
			if vertical_direction * ( @planet.top - top_destination ) > 0 or horizontal_direction * ( @planet.left - left_destination ) > 0
				@planet.remove
				@count.clear
				@animate.stop
			end
		end
	end


end


Shoes.app do

	 planet_shape1 = PlanetShape.new( self , 100 , 100 , 15 , 21, green)
	 planet_shape1.move(200 , 200)



	 planet_shape2 = PlanetShape.new( self , 100 , 100 , 15 , 21, green)
	 planet_shape2.move(400 , 200)

	 planet_shape3 = PlanetShape.new( self , 100 , 100 , 15 , 21, green)	 
	 planet_shape3.move(600 , 400)

	 planet_shape4 = PlanetShape.new( self , 100 , 100 , 15 , 21, green)
	 planet_shape4.move(0 , 400)

	 planet_shape5 = PlanetShape.new( self , 100 , 100 , 15 , 21, green)
	 planet_shape5.move(201 , 0)

	 planet_shape6 = PlanetShape.new( self , 100 , 100 , 15 , 21, green)
	 planet_shape6.move(0 , 0)

	 planet_shape7 = PlanetShape.new( self , 100 , 100 , 15 , 21, green)
	 planet_shape7.move(0 , 40)

	 planet_shape8 = PlanetShape.new( self , 100 , 100 , 15 , 21, green)
	 planet_shape8.move(0 , 180)


	 # alert(planet_shape.count.clear)
	 # alert(planet_shape.planet.left)
	 # planet_shape8.move(200 , 200)
end