# List available pets
# Adopt Pet
# Give up pet

require "sinatra"
require "sinatra/reloader"
require "image_suckr"

require_relative "client"
require_relative "pets"
require_relative "shelter"

suckr = ImageSuckr::GoogleSuckr.new   
pet = Pet.new("Max:dog", "m", "dog")
pet.url = suckr.get_image_url({"q" => "#{pet.type}"})
pet2 = Pet.new("choui", "m", "dog")
pet2.url = suckr.get_image_url({"q" => "#{pet.type}"})


pet.toys=["adsfa", "adfa"]
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

$users = {}
$users["Franky"] = Franky
$users["Max"] = Client.new("Max")
$shelters = {}
$shelters["shelter_1"] = shelter_1
$shelters["shelter_2"] = shelter_2

$curr_user
$curr_shelter
$curr_pet


get "/" do
	erb :index
end
get "/Users/menu" do
	user_name = params[:user_name]
	$curr_user = $users[user_name]
	erb :users
end
get "/Users/Users_Give_away" do
	pet_name = params[:pet_name]
	$curr_pet = $curr_user.pets[pet_name]
	erb :users_give_away_shelter
end

get "/Users/final_give_away" do
	shelter_name = params[:shelter_name]
	$curr_shelter = $shelters[shelter_name]
	$curr_user.give_pet_away($curr_pet, $curr_shelter)
	erb :final_give_away
end

get "/Users/shelter_list_pets" do 
	shelter_name = params[:shelter_name]
	$curr_shelter = $shelters[shelter_name]
	erb :shelter_list_pets
end

get "/Users/adopt_pet" do
	pet_name = params[:pet_name]
	$curr_pet = $curr_shelter.pets[pet_name]
	$curr_user.adopt_pet($curr_pet, $curr_shelter)
	erb :shelter_adopt_final 
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


