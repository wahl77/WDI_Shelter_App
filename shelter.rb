class Shelter 
	attr_accessor :name, :pets
	def initialize(name) 
		@name = name 
		@pets = {}
	end

	def add_pet(pet)
		@pets[pet.name.to_sym] = pet
	end

	def remove_pet(pet)
		@pets.delete(pet.name.to_sym)
	end

	def avail_pets
		if @pets.length == 0
			puts "Sorry, no pets here"
		else
			puts "Shelter #{@name} has pets #{@pets}"
		end

	end
end

