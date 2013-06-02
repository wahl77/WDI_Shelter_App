# List available pets
# Adopt Pet
# Give up pet

require "sinatra"
require "sinatra/reloader"
require "image_suckr"

require_relative "client"
require_relative "pets"
require_relative "shelter"

# Now the program begins
$curr_user
$curr_shelter
$curr_pet

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

def get_user_pet(user_name)
	user_file = "data/people.txt"
	file = File.new(user_file, 'r')
	users = []
	while (line = file.gets)
		words = line.split(",")
		if words[0] == user_name
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



get "/" do
	@users = get_users
	erb :index
end

get "/Users/menu" do
	$curr_user = params[:user_name]
	@pet_info = {}
	@pets = get_user_pet($curr_user)
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
	erb :admin
end

get "/Admin_Validate" do
	@message = ""
	if params[:add_user] != nil
		# Add user
		if $users[params[:add_user]] != nil
			@message =  "Sorry, user exist"
		else
			$users[params[:add_user]] = Client.new(params[:add_user])
			@message = "User added successfully"
		end
	elsif params[:del_user] != nil
		# Del user
		$users.delete(params[:del_user])	
		@message = "User deleted successfully"
	elsif params[:add_shelter] != nil
		# Add shelter
		if $shelters[params[:add_shelter]] != nil
			@message =  "Sorry, Shelter exist"
		else
			$shelters[params[:add_shelter]] = Shelter.new(params[:add_shelter])
			@message = "Shelter added successfully"
		end
	elsif params[:del_shelter] != nil
		# Del shelter
		$shelters.delete(params[:del_shelter])	
		@message = "Shelter deleted successfully"
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
	suckr = ImageSuckr::GoogleSuckr.new   
	@pet.url = suckr.get_image_url({"q" => "#{params[:type]}"})

	$curr_shelter.add_pet(@pet)

	erb :shelter_pet_add
end

get "/Shelter" do
	shelter_name = params[:shelter_name]
	$curr_shelter = $shelters[shelter_name]
	erb :shelter
end


