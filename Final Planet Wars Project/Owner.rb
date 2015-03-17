class Owner
	attr_accessor :id , :color

	def initialize(id )
		@id = id
		@color = Owner.color(id)
	end

	def self.color(owner_id)
		return "red" if owner_id == 1
		return "blue" if owner_id == 2
		return "gray" if owner_id == 0
	end

end
