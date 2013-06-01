class Client
	attr_accessor :pets, :name
	def initialize(name)
		@name = name
		@pets = {}
	end

	def has_pets
		if @pets.length > 0
			@pets
		else
			puts "No pets for #{@name}"
			@pets
		end

	end

	def adopt_pet(pet, shelter)
		@pets[pet.name] = pet
		shelter.remove_pet(pet)
	end

	def give_pet_away(pet, shelter)
		shelter.add_pet(pet)
		@pets.delete(pet.name)
	end

end
