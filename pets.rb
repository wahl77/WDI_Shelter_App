class Pet
	attr_accessor :name, :gender, :type, :toys, :url

	def initialize(name, gender, type)
		@name = name
		@gender = gender
		@type = type
		@toys = []
	end


	#def set_shelter(shelter)
	#	@shelter = shelter
	#end
		
	def get_toys
		if @toys.count == 0
			puts "Sorry, no toys"
		else
			puts "Here are the list of toys for pet #{@name}"
			@toys.each do |x|
				puts x
			end
		end
	end
	
	def add_toy(toys=[])
		if toys.any?
			toys.each do |x|
				@toys << x
			end
		else
			puts "what toy to add?"
			toy = gets.chomp
			@toys << toy
		end
	end


end
