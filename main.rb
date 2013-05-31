# List available pets
# Adopt Pet
# Give up pet

require_relative "client"
require_relative "pets"
require_relative "shelter"

pet = Pet.new("max", "m", "dog")
pet2 = Pet.new("choui", "m", "dog")


pet.add_toy(["adsfa", "adfa"])
pet.get_toys

shelter_1 = Shelter.new("shelter_1")

puts "Shelter 1 has pets:"
print shelter_1.avail_pets
puts "Adding a pet"
shelter_1.add_pet(pet)
print shelter_1.avail_pets
shelter_2 = Shelter.new("shelter_2")
shelter_2.add_pet(pet2)

Franky = Client.new("Franky")

Franky.has_pets
Franky.adopt_pet(pet, shelter_1)
Franky.has_pets

shelter_2.add_pet(pet2)


@users = {}
@users[:franky] = Franky
@shelters = {}
@shelters[:shelter_1] = shelter_1
@shelters[:shelter_2] = shelter_2
#@pets = {}
#@pets[pet.name.to_sym] = pet

@curr_user
@curr_shelter
@curr_pet

def run
	while true
		# Initialze 
		#
		@curr_user = nil
		@curr_shelter = nil
		@curr_pet = nil 
		puts "Are you a (u)ser or (s)helter (a)dmin or here by mistake and (q)uit?" 
		usr_or_shel = gets.chomp.downcase
		
		if usr_or_shel == "q"
			return
		elsif usr_or_shel == "u"
			user_menu_login
		elsif usr_or_shel == "s"
			shelter_menu
		elsif usr_or_shel == "a"
			admin_menu
		else
			puts "Sorry, not understood"
			
		end
	end
end

def admin_menu
	puts "What do you want to do?\n\t 1) Add user \n\t 2) Delete user \n\t 3) Add Shelter \n\t 4) Delete Shelter \n\t 5) Add pet \n\t 6) Delete Pet"
	option = gets.to_i
	case option
	when 1
		add_user
	when 2
		del_user
	when 3
		add_shelter
	when 4
		del_shelter
	when 5 
		add_pet
	when 6
		del_pet
	else
		puts "Not understood"
		return
	end
end

def select_shelter
	puts "Please select a valid shelter from the following:"
	shelter_list
	shelter_name = gets.chomp.downcase
	while @shelters[shelter_name.to_sym] == nil
		puts "Invalid: please select a valid shelter"
		shelter_list
		shelter_name = gets.chomp.downcase
	end
	@curr_shelter = @shelters[shelter_name.to_sym] 
end

def add_shelter
 puts "Existing shelters:"
 shelter_list
 puts "What is the shelter to add?"
	shelter_name = gets.chomp.downcase
	if @shelters[shelter_name.to_sym] != nil
		puts "Sorry, shelter exist"
	else
		shelter = Shelter.new(shelter_name)
		@shelters[shelter_name.to_sym] = shelter
	end
end

def del_shelter
	puts "What shelter do you want to delete?"
	shelter_list
	shelter_name = gets.chomp.downcase
	if @shelters[shelter_name.to_sym] == nil
		puts "Sorry, no shelter named #{shelter_name}"
		return
	else
		@shelters.delete(shelter_name.to_sym)
	end
end

def shelter_list
		@shelters.each do |k, v|
			puts v.name
		end
end

def add_user
	puts "What is the user to add?"
	user_name = gets.chomp.downcase
	if @users[user_name.to_sym] != nil
		puts "Sorry, user exist"
	else
		user = Client.new(user_name)
		@users[user_name.to_sym] = user
	end
end

def del_user
	puts "What user to you want to delete?"
	puts "User list:"
	user_list
	user_name = gets.chomp.downcase
	if @users[user_name.to_sym] == nil
		puts "Sorry, no user name user_name"
		return
	else
		@users.delete(user_name.to_sym)
	end
end

def user_list
	@users.each do |key, user|
		puts user.name
	end
end

def user_menu_login
	puts "What is your name?"
	name = gets.chomp.downcase
	@curr_user = @users[name.to_sym]
	if @curr_user == nil
		puts "Sorry, user does not exist"
	else
		puts "Welcome to you, ${name}"
		user_menu
	end
end

def user_menu
	puts "What do you want to do?"
	puts "\n\t 1) See your pets \n\t 2) Give a pet away \n\t 3) Adopt a pet"
	option = gets.to_i
	case option 
	when 1
		see_user_pets
	when 2
		give_pet_away
	when 3
		adopt_pet
	else 
		puts "Sorry, invalid option"
		return
	end
end

def see_user_pets
	puts @curr_user.has_pets
end

def set_user_dog(pet_name)
	if @curr_user.pets[pet_name.to_sym] == nil
		puts "You do not own this dog"
		return false
	else 
		@curr_pet = @curr_user.pets[pet_name.to_sym]
		return true
	end
end

def give_pet_away
	# Choose a dog
	puts "Plase select a pet to give away (q) to quit"
	see_user_pets
	pet_name = gets.chomp.downcase
	while !set_user_dog(pet_name)  && pet_name != "q"
		if pet_name == "q"
			return
		end
		puts "Invalid pet, plase select a pet to give away (q) to quit"
		see_user_pets
		pet_name = gets.chomp.downcase
	end

	# Choose a shelter
	select_shelter

	@curr_user.give_pet_away(@curr_pet, @curr_shelter)
	puts "Pet givenn away successfully"
end

def set_shelter_pet(pet_name)
	@curr_pet = @curr_shelter.pets[pet_name.to_sym]
	if @curr_pet == nil
		puts "No pet called #{pet_name} at #{@curr_shelter.name}"
		return false
	else
		return true
	end
end

def adopt_pet 
	select_shelter
	puts "Here are the dogs in this shelter"
	@curr_shelter.avail_pets
	puts "Select one"
	pet_name = gets.chomp.downcase

	while !set_shelter_pet(pet_name)
		puts "You have selected an invalid pet"
		@curr_shelter.avail_pets
		pet_name = gets.chomp.downcase
	end
	info
	@curr_user.adopt_pet(@curr_pet, @curr_shelter)
end

def shelter_menu
	see_pets
	add_pet
	remove_pet
end

def info
	puts "---Pets"
	puts @curr_pet
	puts "---User"
	puts @curr_user
	puts "--- Shelter"
	puts @curr_shelter
end
#def usr_menu
#	puts "What is your name"
#	name = gets.chomp.downcase
#	if @users[name.to_sym] == nil
#		puts "We are creating a new user"
#		@curr_user = Client.new(name)
#		@users[name.to_sym] = @curr_user
#	else 
#		puts "Welcome #{name}"
#		@curr_user = @users[name.to_sym]
#	end
#
#	puts "\t1)Browse shelters\n\t2) Give pet away"
#	option = gets.chomp
#
#	case option
#	when "1"
#		puts "Which shelter do you want to browse"
#		view_shelter_list
#		@curr_shelter = @shelters[gets.chomp.downcase.to_sym]
#		browse_shelter(@curr_shelter.name)
#
#	when "2"
#		puts "Here are the pets you can give away"
#		@curr_user.has_pets
#		give_away_pet
#	end
#end
#
#def view_shelter_list
#		@shelters.each do |k, v|
#			puts v.name
#		end
#end
#
#def view_user_pets
#	@curr_user.has_pets
#end
#
#def add_shelter(shelter_name)
#		puts "Adding a shelter with"
#		@curr_shelter = Shelter.new(shelter_name)
#end
#
#def set_shelter(shelter_name)
#	if @shelters[shelter_name.to_sym]==nil
#		return false
#	else
#
#
#def browse_shelter(shelter_name)
#	if @shelters[shelter_name.to_sym]==nil
#		@shelters[shelter_name.to_sym] = @curr_shelter
#		puts "Shelter has no pets"
#		return
#	else 
#		pet_interface
#	end
#end
#
#def pet_interface
#	puts "Here are the pets in shelter #{@curr_shelter.name}"
#	print @curr_shelter.avail_pets
#	puts "Which one to adopt?" 
#	@curr_pet_name = gets.chomp.downcase
#	adopt_pet
#end
#
#def adopt_pet
#	my_pet = @curr_shelter.pets[@curr_pet_name.to_sym] 
#	if my_pet == nil
#		puts "Sorry, shelter does not have this pet"
#		return
#	else
#		@curr_user.adopt_pet(my_pet, @curr_shelter)
#	end
#	return
#end
#
#def give_away_pet
#	my_pet = @users[@curr_user_name.to_sym].pets[@curr_pet_name]
#	if my_pet == nil
#		puts "Sorry, you do not have this pet"
#		return
#	else
#		puts "To which shelter dot you want to give away #{@my_pet.name}"
#		view_shelter_list
#
#		@curr_user.give_pet_away(my_pet, @current_shelter)
#	end
#
#end



	




	
	


		




	



			
run
