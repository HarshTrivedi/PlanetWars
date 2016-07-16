class FilePath
	@@data_path = File.join(   File.expand_path(File.dirname(__FILE__) ) , "data" )
	def self.planet_image(color)
		File.join(@@data_path , "planet_image_#{color}.png")
	end

	def self.galaxy_image(map_id)
		File.join(@@data_path , "galaxy_image_#{map_id}.jpg")
	end

	def self.background_image_home
		File.join(@@data_path , "background_image_home.jpg")
	end

	def self.background_image_options
		File.join(@@data_path , "background_image_options.jpg")
	end

	def self.background_image_gameover
		File.join(@@data_path , "background_image_gameover.jpg")
	end	

	def self.map(map_id)
		File.join(@@data_path , "map_#{id}.txt")
	end

	def self.back_button_image
		File.join(@@data_path , "back_button_image.png")
	end

	def self.data_path
		@@data_path
	end

end

