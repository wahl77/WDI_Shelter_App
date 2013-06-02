# List available pets
# Adopt Pet
# Give up pet

require "sinatra"
require "sinatra/reloader"
require "image_suckr"

# For file manipulation
require 'fileutils'
require 'tempfile'

require_relative "client"
require_relative "pets"
require_relative "shelter"

# Use this to store session information
$curr_user
$curr_shelter
$curr_pet
# End of session information
#

def add_owner(owner_name, owner_type)
	if owner_type == "client"
		file = "data/people.txt"
	elsif owner_type == "shelter"
		file = "data/shelter.txt"
	end
	file = File.new(file, 'r')
	while (line = file.gets)
		words = line.split(",")
		if words[0] == owner_name
			file.close
			return "Error, owner exist"
		end
	end
	file = File.new(file, 'a')
	file.puts owner_name + ",," 
	file.close
	return "Owner added successfully"
end



def get_users
	user_file = "data/people.txt"
	file = File.new(user_file, 'r')
	users = []
	while (line = file.gets)
		words = line.split(",")
		users << words[0]
	end
	return users
end

def get_owner_pet(owner_name, owner_type)
	if owner_type == "client"
		file = "data/people.txt"
	elsif owner_type == "shelter"
		file = "data/shelter.txt"
	end

	file = File.new(file, 'r')
	owner = []
	while (line = file.gets)
		words = line.split(",")
		if words[0] == owner_name
			dogs = words[1].split("|")
			return dogs
		end
	end
end

def get_pet_info(pet_name)
	pet_file = "data/pets.txt"
	file = File.new(pet_file, 'r')
	pet_info = []
	while (line = file.gets)
		words = line.split(",")
		if words[0] == pet_name
			pet_info = words
			return pet_info
		end
	end
end

def get_shelters
	shelter_file = "data/shelter.txt"
	file = File.new(shelter_file, 'r')
	shelters = []
	while (line = file.gets)
		words = line.split(",")
		shelters << words[0]
	end
	return shelters
end


get "/" do
	@users = get_users
	@shelters = get_shelters
	erb :index
end

get "/Users/menu" do
	$curr_user = params[:user_name]
	@pet_info = {}
	@pets = get_owner_pet($curr_user, "client")
	@pets.each do |pet|
		@pet_info[pet] = get_pet_info(pet)
	end
	erb :users
end



get "/Users/Users_Give_away" do
	begin
		pet_name = params[:pet_name]
		$curr_pet = $curr_user.pets[pet_name]
		erb :users_give_away_shelter
	rescue
		erb :index
	end
end

get "/Users/final_give_away" do
	begin
		shelter_name = params[:shelter_name]
		$curr_shelter = $shelters[shelter_name]
		$curr_user.give_pet_away($curr_pet, $curr_shelter)
		erb :final_give_away
	rescue
		erb :index
	end

end

get "/Users/shelter_list_pets" do 
	begin
		shelter_name = params[:shelter_name]
		$curr_shelter = $shelters[shelter_name]
		erb :shelter_list_pets
	rescue
		erb :index
	end
end

get "/Users/adopt_pet" do
	begin
		pet_name = params[:pet_name]
		$curr_pet = $curr_shelter.pets[pet_name]
		$curr_user.adopt_pet($curr_pet, $curr_shelter)
		erb :shelter_adopt_final 
	rescue
		erb :index
	end
end

get "/Users/shelter_list" do
	erb :shelter_list
end

get "/Admin" do
	@users = get_users
	@shelters = get_shelters
	erb :admin
end

get "/Admin_Validate" do
	@users = get_users
	@shelters = get_shelters
	@message = ""
	if params[:add_user] != nil
		# Add user
		@message =  add_owner(params[:add_user], "client")
	elsif params[:del_user] != nil
		# Del user
		@message = remove_owner(params[:del_user], "client")	
	elsif params[:add_shelter] != nil
		# Add shelter
		@message =  add_owner(params[:add_shelter], "shelter")
	elsif params[:del_shelter] != nil
		# Del shelter
		@message = remove_owner(params[:del_shelter], "shelter")	
	else
		@message = "Error"
	end
	erb :admin_validate
end

get "/shelter_delete_pet" do
	begin
		pet_name = params[:pet_name]
		$curr_pet = $curr_shelter.pets[pet_name]
		$curr_shelter.remove_pet($curr_pet)
		erb :shelter_del_pet
	rescue
		erb :index
	end
end

get "/shelter_add_pet" do
	@pet = Pet.new(params[:pet_name], params[:gender], params[:type]) 
	@pet.add_toy([params[:toys]])
	suckr = ImageSuckr::GoogleSuckr.new   
	@pet.url = suckr.get_image_url({"q" => "#{params[:type]}"})
	add_pet(@pet)
	add_pet_owner($curr_shelter, "shelter", @pet.name)

	erb :shelter_pet_add
end

get "/Shelter" do
	$curr_shelter = params[:shelter_name]
	@pet_info = {}
	@pets = get_owner_pet($curr_shelter, "shelter")
	@pets.each do |pet|
		@pet_info[pet] = get_pet_info(pet)
	end
	erb :shelter
end

def add_pet(pet)
	file = "data/pets.txt"
	file = File.new(file, 'r')
	while (line = file.gets)
		words = line.split(",")
		if words[0] == pet.name
			file.close
			return "Error, Pet exist"
		end
	end
	file = File.new(file, 'a')
	file.puts pet.name + "," + pet.gender + "," + pet.type + "," + pet.url + "," + pet.toys[0]
	file.close
	return "Pet added successfully" 
end

def add_pet_owner(owner_name, owner_type, pet_name)
	t_file = Tempfile.new('temp.txt')

	if owner_type == "client"
		file = "data/people.txt"
	elsif owner_type == "shelter"
		file = "data/shelter.txt"
	end
	file = File.open(file, 'r')
	while (line = file.gets)
		if line.split(",")[0] == owner_name
			t_file.write line.gsub(/[,]$/,'|'+pet_name+',')
		end
	end
	t_file.close

	FileUtils.mv(t_file.path, file)
	return "Owner delted succesfully" 
end


def remove_owner(owner_name, owner_type)
	t_file = Tempfile.new('temp.txt')

	if owner_type == "client"
		file = "data/people.txt"
	elsif owner_type == "shelter"
		file = "data/shelter.txt"
	end
	file = File.open(file, 'r')
	while (line = file.gets)
		unless line.split(",")[0] == owner_name
			t_file.write line
		end
	end
	t_file.close

	FileUtils.mv(t_file.path, file)

	return "Owner delted succesfully"

end
