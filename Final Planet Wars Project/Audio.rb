class Audio
	def self.play(sound)
		path = File.join( FilePath.data_path , "#{sound}.mp3")
		puts path
		puts "mpg123 -q #{path} &"
		system("mpg123 -q #{path} &")
	end
end
