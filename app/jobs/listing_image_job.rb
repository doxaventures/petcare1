class ListingImageJob < Struct.new(:community_id,:file)
  require 'csv'
  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
 
  def perform
    @community = Community.find(community_id)
    @author = Person.where(username: "petstore").first.id
    
  total_categories = { "Treats & Snacks>Dental Dog Bones " => "Dog Supplies/Treats & Snacks",
  "Treats & Snacks>Chews " => "Dog Supplies/Treats & Snacks",
  "Dog Crates & Kennels>Soft-Sided Carriers " => "Dog Supplies/Crates & Kennels",
  "Clean Up, Stain & Odor Control>Pet Stain & Odor Control " => "Dog Supplies/Clean Up",
  "Health Care, Supplements & Nutrition>Skin & Coat Treatments " => "Dog Supplies/Health Care Supplies",
  "Grooming Supplies>Shampoo & Conditioners " => "Dog Supplies/Grooming Supplies",
  "Treats & Snacks>Biscuits " => "Dog Supplies/Treats & Snacks",
  "Health Care, Supplements & Nutrition>Vitamins & Supplements " => "Dog Supplies/Health Care Supplies",
  "Health Care, Supplements & Nutrition>Arthritis & Joint Care " => "Dog Supplies/Health Care Supplies",
  "Dog Clothing & Apparel>T-Shirts " => "Dog Supplies/Clothing & Apparel",
  "Toys>Rope & Tug Toys " => "Dog Supplies/Toys",
  "Treats & Snacks>Natural & Smoked Treats " => "Dog Supplies/Treats & Snacks",
  "Flea & Tick>Flea & Tick Shampoo " => "Dog Supplies/Flea & Tick",
  "Flea & Tick>Flea & Tick Powders & Sprays " => "Dog Supplies/Flea & Tick",
  "Training & Behavior>Dog & Puppy Repellents " => "Dog Supplies/Training & Behavior",
  "Health Care, Supplements & Nutrition>Allergy & Stress Relief " => "Dog Supplies/Health Care Supplies",
  "Flea & Tick>Home & Yard Treatments " => "Dog Supplies/Flea & Tick",
  "Clean Up, Stain & Odor Control>House Training & Incontinence>Diapers " => "Dog Supplies/Clean Up",
  "Clean Up, Stain & Odor Control>House Training & Incontinence " => "Dog Supplies/Clean Up",
  "Clean Up, Stain & Odor Control>Outdoor & Yard Products " => "Dog Supplies/Clean Up",
  "Flea & Tick>Flea & Tick Spot On " => "Dog Supplies/Flea & Tick",
  "Grooming Supplies>Hair Clippers " => "Dog Supplies/Grooming Supplies",
  "Grooming Supplies>Nail Clippers " => "Dog Supplies/Grooming Supplies",
  "Grooming Supplies " => "Dog Supplies/Grooming Supplies",
  "Dog Clothing & Apparel>Boots & Outdoor Accessories " => "Dog Supplies/Clothing & Apparel",
  "Dog Clothing & Apparel>Sweaters & Coats " => "Dog Supplies/Clothing & Apparel",
  "Treats & Snacks>Rawhide " => "Dog Supplies/Treats & Snacks",
  "Grooming Supplies>Pet Wipes " => "Dog Supplies/Grooming Supplies",
  "Health Care, Supplements & Nutrition>Eye & Ear Health Care " => "Dog Supplies/Health Care Supplies",
  "Health Care, Supplements & Nutrition>Dental Care & Toothbrushes " => "Dog Supplies/Health Care Supplies",
  "Clean Up, Stain & Odor Control>House Training & Incontinence>Wee Pads " => "Dog Supplies/Clean Up",
  "Toys>Chew Toys " => "Dog Supplies/Toys",
  "Health Care, Supplements & Nutrition>First Aid " => "Dog Supplies/Health Care Supplies",
  "Training & Behavior " => "Dog Supplies/Training & Behavior",
  "Grooming Supplies>Brushes & Combs " => "Dog Supplies/Grooming Supplies",
  "Dog Collars, Leashes & Harnesses>Dog Leashes & Leads " => "Dog Supplies/Collars, Leashes, Harnesses",
  "Dog Collars, Leashes & Harnesses>Collars " => "Dog Supplies/Collars, Leashes, Harnesses",
  "Dog Collars, Leashes & Harnesses>Tie Out Cables & Stakes " => "Dog Supplies/Collars, Leashes, Harnesses",
  "Dog Collars, Leashes & Harnesses>Dog Harnesses " => "Dog Supplies/Collars, Leashes, Harnesses",
  "Dog Collars, Leashes & Harnesses>Training Collars & Harnesses " => "Dog Supplies/Collars, Leashes, Harnesses",
  "Dog Collars, Leashes & Harnesses>Dog Muzzles " => "Dog Supplies/Collars, Leashes, Harnesses",
  "Toys>Plush & Squeaker Toys " => "Dog Supplies/Toys",
  "Flea & Tick>Flea & Tick Combs " => "Dog Supplies/Flea & Tick",
  "Toys>Rubber & Vinyl Toys " => "Dog Supplies/Toys",
  "Dog Doors & Gates>Dog Gates " => " Dog Supplies/Doors & Gates",
  "Dog Crates & Kennels>Vari Kennels & Carriers " => "Dog Supplies/Crates & Kennels",
  "Dog Crates & Kennels>Crate & Kennel Accessories " => "Dog Supplies/Crates & Kennels",
  "Bowls, Feeders, & Waterers>Placemats & Food Scoops " => "Dog Supplies/Feeders & Waterers",
  "Bowls, Feeders, & Waterers>Automatic Feeders & Waterers " => "Dog Supplies/Feeders & Waterers",
  "Bowls, Feeders, & Waterers>Food Storage & Containers " => "Dog Supplies/Feeders & Waterers",
  "Dog Houses>Plastic & Soft-Sided " => "Dog Supplies/Dog Houses",
  "Clean Up, Stain & Odor Control>Pooper Scoopers & Bags " => "Dog Supplies/Clean Up",
  "Dog Beds>Crate Mats & Cage Pads " => "Dog Supplies/Beds",
  "Dog Beds>Cushions & Pillows " => "Dog Supplies/Beds",
  "Food>Adult Dog " => "Dog Supplies/Dog Food",
  "Health Care, Supplements & Nutrition>Dog Worm Treatments " => "Dog Supplies/Health Care Supplies",
  "Dog Houses>Replacement Flaps " => "Dog Supplies/Dog Houses",
  "Dog Beds " => "Dog Supplies/Beds",
  "Toys " => "Dog Supplies/Toys",
  "Health Care, Supplements & Nutrition>Milk Replacement & Weaning Formula " => " Dog Supplies/Health Care Supplies",
  "Health Care, Supplements & Nutrition>Digestive Aid " => "Dog Supplies/Health Care Supplies",
  "Flea & Tick>Flea & Tick Collars " => "Dog Supplies/Flea & Tick",
  "Training & Behavior>Behavior Control " => "Dog Supplies/Training & Behavior",
  "Dog Doors & Gates>Dog Doors " => "Dog Supplies/Doors & Gates",
  "Dog Doors & Gates>Replacement Flaps " => "Dog Supplies/Doors & Gates",
  "Dog Crates & Kennels>Folding Wire Crates " => "Dog Supplies/Crates & Kennels",
  "Dog Crates & Kennels>Exercise Pens " => "Dog Supplies/Crates & Kennels",
  "Dog Beds>Loungers & Cuddlers " => "Dog Supplies/Beds",
  "Health Care, Supplements & Nutrition " => "Dog Supplies/Health Care Supplies",
  "Travel & Outdoors>Travel Bowls & Bottles " => "Dog Supplies/Feeders & Waterers",
  "Food>Puppy " => "Dog Supplies/Dog Food",
  "Food>Light & Weight Loss " => "Dog Supplies/Dog Food",
  "Food>Breed Specific " => "Dog Supplies/Dog Food",
  "Food>Senior Dog " => "Dog Supplies/Dog Food",
  "Training & Behavior>Training Accessories " => "Dog Supplies/Training & Behavior",
  "Training & Behavior>Bark Collars & Control " => "Dog Supplies/Training & Behavior",
  "Training & Behavior>Fencing & Containment " => "Dog Supplies/Training & Behavior",
  "Dog Houses>Wood " => "Dog Supplies/Dog Houses",
  "Dog Houses " => "Dog Supplies/Dog Houses",
  "Health Care, Supplements & Nutrition>Medications OTC " => "Dog Supplies/Health Care Supplies",
  "Puppy Supplies>Puppy Grooming Supplies>Brushes & Combs " => "Dog Supplies/Puppy Supplies",
  "Toys>Ball Toys " => "Dog Supplies/Toys",
  "Lighting>Lighting Ballasts & Parts " => "Aquarium & Pond Supplies/Lighting - Bulbs & Parts",
  "Aeration>Airline Tubing & Valves " => "Aquarium & Pond Supplies/Aeration & CO2",
  "Thermometers>Digital Display " => "Aquarium & Pond Supplies/Controllers & Monitors",
  "Heaters>Inline Heaters " => "Aquarium & Pond Supplies/Heaters",
  "Plumbing Parts>Bulkheads & Strainers " => "Aquarium & Pond Supplies/Plumbing",
  "Aquariums & Bowls>Glass Aquariums " => "Aquarium & Pond Supplies/Aquariums",
  "Water Pumps>External Pumps & Accessories " => "Aquarium & Pond Supplies/Pumps & Powerheads",
  "Water Pumps>External Pumps & Accessories>Replacement Parts & Accessories " => "Aquarium & Pond Supplies/Pumps & Powerheads",
  "Aeration>Air Pumps " => "Aquarium & Pond Supplies/Aeration & CO2",
  "Filter Media>Chemical " => "Aquarium & Pond Supplies/Filter Media",
  "Lighting>Lighting Ballasts & Parts>Fluorescent Parts " => "Aquarium & Pond Supplies/Lighting - Bulbs & Parts",
  "Lighting>Fully Assembled Fixtures>T5 & T12 Fixtures " => "Aquarium & Pond Supplies/Lighting - Fixtures",
  "Lighting>Bulbs>Fluorescent Tubes " => "Aquarium & Pond Supplies/Lighting - Bulbs & Parts",
  "Backgrounds & Decor>Life-Like Decor " => "Aquarium & Pond Supplies/Decor & Substrate",
  "Backgrounds & Decor>Decorations " => "Aquarium & Pond Supplies/Decor & Substrate",
  "Filters>Power Filters " => "Aquarium & Pond Supplies/Filtration",
  "Filter Media>Media Cartridges " => "Aquarium & Pond Supplies/Filter Media",
  "Maintenance>Siphons & Gravel Cleaning " => "Aquarium & Pond Supplies/Maintenance Supplies",
  "Filters>Internal Filters " => "Aquarium & Pond Supplies/Filtration",
  "Filter Media>Mechanical " => "Aquarium & Pond Supplies/Filter Media",
  "Filter Media>Biological " => "Aquarium & Pond Supplies/Filter Media",
  "Fish Food & Reef Food>Flake & Pellet Food " => " Aquarium & Pond Supplies/Food",
  "Fish Food & Reef Food>Bottom Feeder Food " => "Aquarium & Pond Supplies/Food",
  "Backgrounds & Decor>Rock & Driftwood " => "Aquarium & Pond Supplies/Decor & Substrate",
  "Water Testing>Test Kits " => "Aquarium & Pond Supplies/Water Testing",
  "Additives & Supplements>Water Conditioners & Buffers " => "Aquarium & Pond Supplies/Additives & Supplements",
  "Medications & Treatments>Algae Removers " => "Aquarium & Pond Supplies/Medications",
  "Additives & Supplements>Water Clarifiers " => "Aquarium & Pond Supplies/Additives & Supplements",
  "Medications & Treatments>Fungal & Bacterial " => "Aquarium & Pond Supplies/Medications",
  "Filters>Canister Filters " => "Aquarium & Pond Supplies/Filtration",
  "Saltwater Supplies>Protein Skimmers " => "Aquarium & Pond Supplies/Saltwater Specialty",
  "Aquariums & Bowls>Aquarium Stands & Hoods " => "Aquarium & Pond Supplies/Aquariums",
  "Water Pumps>Powerheads & Accessories>Replacement Parts & Accessories " => "Aquarium & Pond Supplies/Pumps & Powerheads",
  "Lighting>LED Lights & Moonlights>LED Lights " => "Aquarium & Pond Supplies/Lighting - Fixtures",
  "Filters>Inline & Specialty Filters " => "Aquarium & Pond Supplies/Filtration",
  "Additives & Supplements>Vitamins & Supplements " => "Aquarium & Pond Supplies/Additives & Supplements",
  "Freshwater Supplies>Freshwater Supplements " => "Aquarium & Pond Supplies/Freshwater Specialty",
  "Freshwater Supplies>Freshwater Gravel & Substrate "=> "Aquarium & Pond Supplies/Decor & Substrate",
  "Saltwater Supplies>Salt Mix "=> "Aquarium & Pond Supplies/Saltwater Specialty",
  "Saltwater Supplies>Substrate "=> "Aquarium & Pond Supplies/Saltwater Specialty",
  "Additives & Supplements>Bio Additives "=> "Aquarium & Pond Supplies/Additives & Supplements",
  "Lighting>Bulbs>Power Compact Bulbs "=> "Aquarium & Pond Supplies/Lighting - Bulbs & Parts",
  "Medications & Treatments>Ich & External Parasites "=> "Aquarium & Pond Supplies/Medications",
  "Maintenance>Fish Nets & Containment "=> "Aquarium & Pond Supplies/Maintenance Supplies",
  "Thermometers>Internal Floating & Standing "=> "Aquarium & Pond Supplies/Controllers & Monitors",
  "Saltwater Supplies>Coral Propagation Supplies>Miscellaneous Coral Propagation "=> "Aquarium & Pond Supplies/Saltwater Specialty",
  "Fish Food & Reef Food>Feeding Tools "=> "Aquarium & Pond Supplies/Food",
  "Maintenance>Scrapers, Pads & Brushes "=> "Aquarium & Pond Supplies/Maintenance Supplies",
  "Aeration>Air Diffusers "=> "Aquarium & Pond Supplies/Aeration & CO2",
  "Filter Media>Media Bags "=> " Aquarium & Pond Supplies/Filter Media",
  "Plumbing Parts>Tubing "=> "Aquarium & Pond Supplies/Plumbing",
  "Controllers & Monitors>Single Function "=> "Aquarium & Pond Supplies/Controllers & Monitors",
  "Filters>Overflow Boxes "=> "Aquarium & Pond Supplies/Filtration",
  "Filters>Wet-Dry Filters & Sumps "=> "Aquarium & Pond Supplies/Filtration",
  "Plumbing Parts>Loc-Line Fittings & Return Tubes "=> "Aquarium & Pond Supplies/Plumbing",
  "Water Pumps>Powerheads & Accessories>Powerheads "=> "Aquarium & Pond Supplies/Pumps & Powerheads",
  "Saltwater Supplies>Wavemakers "=> "Aquarium & Pond Supplies/Saltwater Specialty",
  "CO2 Systems & Accessories>CO2 Systems "=> "Aquarium & Pond Supplies/Aeration & CO2",
  "CO2 Systems & Accessories>CO2 Accessories "=> "Aquarium & Pond Supplies/Aeration & CO2",
  "Maintenance>Algae Magnet Cleaners "=> "Aquarium & Pond Supplies/Maintenance Supplies",
  "Freshwater Supplies>Plant Care Additives "=> "Aquarium & Pond Supplies/Freshwater Specialty",
  "Heaters>In-Tank Heaters "=> "Aquarium & Pond Supplies/Heaters",
  "Aquariums & Bowls>Aquarium Kits "=> "Aquarium & Pond Supplies/Aquariums",
  "Fish Food & Reef Food>Freeze Dried Food " => "Aquarium & Pond Supplies/Food",
  "Aquariums & Bowls>Small Aquariums & Bowls " => "Aquarium & Pond Supplies/Aquariums",
  "Wild Bird>Wild Bird Food " => "Bird Supplies/Bird Food",
  "Food>Finch & Canary " => "Bird Supplies/Bird Food",
  "Treats & Snacks>Millet Spray " => "Bird Supplies/Treats & Snacks",
  "Food>Cockatiel " => "Bird Supplies/Bird Food",
  "Food>Parakeet (Budgie) " => "Bird Supplies/Bird Food",
  "Food>Parrot & Large Hookbill " => "Bird Supplies/Bird Food",
  "Treats & Snacks>Macaw & Cockatoo " => "Bird Supplies/Treats & Snacks",
  "Food>Conure & Small Hookbill " => "Bird Supplies/Bird Food",
  "Food>Macaw & Cockatoo " => "Bird Supplies/Bird Food",
  "Grooming Supplies>Bird Bath Sprays " => "Bird Supplies/Grooming Supplies",
  "Health Care, Supplements & Nutrition>Diarrhea Treatment & Digestion Aid " => "Bird Supplies/Health Care Supplies",
  "Health Care, Supplements & Nutrition>Mite Protectors & Lice Control " => "Bird Supplies/Health Care Supplies",
  "Cage Accessories, Play Stands & Carriers>Perches " => "Bird Supplies/Cage Accessories",
  "Treats & Snacks>Parrot & Large Hookbill " => "Bird Supplies/Treats & Snacks",
  "Treats & Snacks>Conure & Small Hookbill " => "Bird Supplies/Treats & Snacks",
  "Food>Wild Bird & Hummingbird " => "Bird Supplies/Bird Food",
  "Bird Feeders & Waterers>Waterers " => "Bird supplies/Feeders & Waterers",
  "Bird Feeders & Waterers>Food Storage " => "Bird supplies/Feeders & Waterers",
  "Bird Feeders & Waterers>Cage Cups & Bowls " => "Bird supplies/Feeders & Waterers",
  "Health Care, Supplements & Nutrition>Mineral Blocks & Cuttlebones " => "Bird Supplies/Health Care Supplies",
  "Cage Litter, Liners & Nesting>Walnut Shell, Pelletized & Corn Cob " => "Bird Supplies/Litter & Liners",
  "Cage Litter, Liners & Nesting>Wood Shavings " => "Bird Supplies/Litter & Liners",
  "Treats & Snacks>Finch & Canary " => "Bird Supplies/Treats & Snacks",
  "Treats & Snacks>Treat Sticks " => "Bird Supplies/Treats & Snacks",
  "Treats & Snacks>Parakeet (Budgie) " => "Bird Supplies/Treats & Snacks",
  "Treats & Snacks>Cockatiel " => "Bird Supplies/Treats & Snacks",
  "Cage Litter, Liners & Nesting>Paper Bedding " => "Bird Supplies/Litter & Liners",
  "Food>Breeding & Hand Feeding " => "Bird Supplies/Bird Food",
  "Cage Accessories, Play Stands & Carriers>Ladders " => "Bird Supplies/Cage Accessories",
  "Cage Litter, Liners & Nesting>Cage Liners " => "Bird Supplies/Litter & Liners",
  "Cage Accessories, Play Stands & Carriers>Swings " => "Bird Supplies/Cage Accessories",
  "Cage Accessories, Play Stands & Carriers>Playpens " => "Bird Supplies/Cage Accessories",
  "Toys>Parakeet (Budgie) " => "Bird Supplies/Toys",
  "Toys>Macaw & Cockatoo " => "Bird Supplies/Toys",
  "Food " => "Bird Supplies/Bird Food",
  "Lighting, Heaters & Timers>Light Fixtures " => "Bird Supplies/Lighting & Heating",
  "Cage Accessories, Play Stands & Carriers>Nets " => "Bird Supplies/Cage Accessories",
  "Cage Litter, Liners & Nesting>Tunnels & Cozys " => "Bird Supplies/Cage Accessories",
  "Cage Litter, Liners & Nesting>Nests & Nesting Material " => "Bird Supplies/Cage Accessories",
  "Toys>Parrot & Large Hookbill " => "Bird Supplies/Toys",
  "Wild Bird>Wild Bird Feeders and Waterers " => "Bird supplies/Feeders & Waterers",
  "Cage Bedding, Liners & Scoops>Paper Bedding " => "Small Pet Services & Supplies/Litter & Liners",
  "Pet Food>Rat & Mouse " => "Small Pet Services & Supplies/Food",
  "Pet Food>Chinchilla " => "Small Pet Services & Supplies/Food",
  "Treats & Snacks>Vitamin Treats " => "Small Pet Services & Supplies/Treats & Snacks",
  "Treats & Snacks>Alfalfa & Hay Accessories " => "Small Pet Services & Supplies/Treats & Snacks",
  "Cages & Habitats>Wire Cages " => "Small Pet Services & Supplies/Cages & Habitats",
  "Cages & Habitats>Ferret Cages " => "Small Pet Services & Supplies/Cages & Habitats",
  "Cage Accessories, Beds & Nesting>Nests & Nesting Material " => "Small Pet Services & Supplies/Cage Accessories",
  "Small Animal Toys>Chews " => "Small Pet Services & Supplies/Toys",
  "Cage Accessories, Beds & Nesting>Igloos " => "Small Pet Services & Supplies/Cage Accessories",
  "Health Care, Supplements & Nutrition>Chinchilla Dust " => "Small Pet Services & Supplies/Health Care Supplies",
  "Cages & Habitats>Hamster Critter Trails " => "Small Pet Services & Supplies/Cages & Habitats",
  "Cage Bedding, Liners & Scoops>Training Litter " => "Small Pet Services & Supplies/Litter & Liners",
  "Feeders & Water Bottles>Feeders & Water Bottles " => "Small Pet Services & Supplies/Feeders & Waterers",
  "Treats & Snacks>Treat Sticks & Holders " => "Small Pet Services & Supplies/Treats & Snacks",
  "Treats & Snacks>Dental Chews & Salt Licks " => "Small Pet Services & Supplies/Treats & Snacks",
  "Cage Bedding, Liners & Scoops>Litter Pans & Boxes " => "Small Pet Services & Supplies/Litter & Liners",
  "Small Animal Toys>Exercise Wheels & Balls " => "Small Pet Services & Supplies/Toys",
  "Treats & Snacks>Fruit Treats " => "Small Pet Services & Supplies/Treats & Snacks",
  "Cage Accessories, Beds & Nesting>Hammocks & Tunnels " => "Small Pet Services & Supplies/Cage Accessories",
  "Cages & Habitats>Exercise Pens " => "Small Pet Services & Supplies/Cages & Habitats",
  "Cage Accessories, Beds & Nesting>Beds " => "Small Pet Services & Supplies/Cage Accessories",
  "Collars, Leashes & Carriers>Harnesses " => "Small Pet Services & Supplies/Collars & Carriers",
  "Collars, Leashes & Carriers>Soft-Sided Carriers " => "Small Pet Services & Supplies/Collars & Carriers",
  "Grooming Supplies>Brushes & Clippers " => "Small Pet Services & Supplies/Grooming Supplies",
  "Cage Cleaners & Odor Removers>Cage Cleaners " => "Small Pet Services & Supplies/Litter & Liners",
  "Cages & Habitats>Outdoor Hutches " => "Small Pet Services & Supplies/Cages & Habitats",
  "Collars, Leashes & Carriers>Collars " => "Small Pet Services & Supplies/Collars & Carriers",
  "Small Animal Toys>Mazes & Puzzles " => "Small Pet Services & Supplies/Toys",
  "Small Animal Toys " => "Small Pet Services & Supplies/Toys",
  "Pet Food>Hedgehog & Squirrel " => "Small Pet Services & Supplies/Food",
  "Pet Food>Other Small Animal Food " => "Small Pet Services & Supplies/Food",
  "Treats & Snacks>Rabbit Treats " => "Small Pet Services & Supplies/Treats & Snacks",
  "Small Animal Toys>Hideaways & Furniture " => "Small Pet Services & Supplies/Toys",
  "Cage Bedding, Liners & Scoops>Wood Shavings " => "Small Pet Services & Supplies/Litter & Liners",
  "Cage Bedding, Liners & Scoops>Walnut Shell, Pelletized & Corn Cob " => "Small Pet Services & Supplies/Litter & Liners",
  "Pet Food>Ferret " => "Small Pet Services & Supplies/Food",
  "Pet Food>Guinea Pig " => "Small Pet Services & Supplies/Food",
  "Pet Food>Hamster & Gerbil " => "Small Pet Services & Supplies/Food",
  "Pet Food>Rabbit " => "Small Pet Services & Supplies/Food",
  "Pet Food>Primate " => "Small Pet Services & Supplies/Food",
  "Treats & Snacks>Ferret Treats " => "Small Pet Services & Supplies/Treats & Snacks",
  "Collars, Leashes & Carriers>Cardboard Carriers " => "Small Pet Services & Supplies/Collars & Carriers",
  "Feeders & Water Bottles>Cage Cups & Bowls " => "Small Pet Services & Supplies/Feeders & Waterers",
  "Cage Accessories, Beds & Nesting>Screen Cage Covers " => "Small Pet Services & Supplies/Cage Accessories",
  "Koi Food & Fish Feeders>Feeders & Feeding Blocks " => "Aquarium & Pond Supplies/Pond Specialty",
  "Water Treatments>Algae Control>Clarifiers " => "Aquarium & Pond Supplies/Pond Specialty",
  "Medications>Pond Salt " => "Aquarium & Pond Supplies/Pond Specialty",
  "Koi Food & Fish Feeders>Floating Sticks " => "Aquarium & Pond Supplies/Pond Specialty",
  "Fish Nets>Pond Netting " => "Aquarium & Pond Supplies/Pond Specialty",
  "Water Treatments>Algae Control>Chemical Additives " => "Aquarium & Pond Supplies/Pond Specialty",
  "Filters>Replacement Parts & Accessories " => "Aquarium & Pond Supplies/Pond Specialty",
  "UV Sterilizers & Clarifiers>Replacement Parts>Lamps " => "Aquarium & Pond Supplies/Pond Specialty",
  "UV Sterilizers & Clarifiers>UV Sterilizers " => "Aquarium & Pond Supplies/Pond Specialty",
  "Filters>External Pressurized Filters>Foam " => "Aquarium & Pond Supplies/Pond Specialty",
  "Pumps>External Pumps>Standard " => "Aquarium & Pond Supplies/Pond Specialty",
  "Filters>Submersible Filters " => "Aquarium & Pond Supplies/Pond Specialty",
  "Filters>Pond Skimmers " => "Aquarium & Pond Supplies/Pond Specialty",
  "Koi Food & Fish Feeders>Pellet Food " => "Aquarium & Pond Supplies/Pond Specialty",
  "Pumps>Submersible Pumps " => "Aquarium & Pond Supplies/Pond Specialty",
  "Pond Kits " => "Aquarium & Pond Supplies/Pond Specialty",
  "Mosquito Control " => "Aquarium & Pond Supplies/Pond Specialty",
  "Water Treatments>Water Conditioners " => "Aquarium & Pond Supplies/Pond Specialty",
  "Water Treatments>Combination & Specialty Additives " => "Aquarium & Pond Supplies/Pond Specialty",
  "Aeration>Aeration Kits " => "Aquarium & Pond Supplies/Pond Specialty",
  "Medications>Fungal Medications " => "Aquarium & Pond Supplies/Pond Specialty",
  "Koi Food & Fish Feeders>Treats & Supplements " => "Aquarium & Pond Supplies/Pond Specialty",
  "Plumbing Parts>Tubing>Flexible Tubing " => "Aquarium & Pond Supplies/Plumbing",
  "Training, Behavior & Repellent>Cat & Kitten Repellent " => " Cat Supplies/Training & Behavior",
  "Collars, Leashes & Harnesses>Collars " => "Cat Supplies/Collars, Leashes, Harnesses",
  "Flea & Tick Treatments>Flea & Tick Combs " => "Cat Supplies/Flea & Tick   ",
  "Treats & Snacks>Soft Treats " => " Cat Supplies/Treats & Snacks",
  "Cat Litter, Stain & Odor Control>Litter " => " Cat Supplies/Litter & Odor Control",
  "Cat Litter, Stain & Odor Control>Litter Scoops & Mats " => " Cat Supplies/Litter & Odor Control",
  "Cages & Carriers>Vari Kennels & Carriers " => "Cat Supplies/Cages & Carriers",
  "Cat Litter, Stain & Odor Control>Litter Pans & Boxes " => "Cat Supplies/Litter & Odor Control",
  "Bowls, Feeders, & Waterers>Bowls & Stands " => " Cat Supplies/Feeders & Waterers",
  "Cat Litter, Stain & Odor Control>Liners & Replacement Filters " => "Cat Supplies/Litter & Odor Control",
  "Cat Litter, Stain & Odor Control>Stain & Odor Control " => "Cat Supplies/Litter & Odor Control",
  "Toys>Catnip Toys " => "Cat Supplies/Toys",
  "Cat Furniture & Scratchers>Scratchers & Scratching Posts " => "Cat Supplies/Furniture & Scratchers",
  "Toys>Interactive Toys & Teasers " => "Cat Supplies/Toys",
  "Cat Litter, Stain & Odor Control>Disposable Litter " => "Cat Supplies/Litter & Odor Control",
  "Treats & Snacks " => "Cat Supplies/Treats & Snacks",
  "Flea & Tick Treatments>Flea & Tick Spot On " => "Cat Supplies/Flea & Tick ",
  "Flea & Tick Treatments>Flea & Tick Collars " => "Cat Supplies/Flea & Tick ",
  "Training, Behavior & Repellent " => "Cat Supplies/Training & Behavior",
  "Health Care, Supplements & Nutrition>Hairball Remedy " => "Cat Supplies/Health Care Supplies",
  "Treats & Snacks>Catnip & Cat Grass " => "Cat Supplies/Treats & Snacks",
  "Cat Food>Kitten " => "Cat Supplies/Cat Food",
  "Cat Food>Indoor Cat " => "Cat Supplies/Cat Food",
  "Cat Food>Light & Weight Loss " => "Cat Supplies/Cat Food",
  "Treats & Snacks>Crunchy Treats " => "Cat Supplies/Treats & Snacks",
  "Toys>Plush, Mice & Fur Toys " => "Cat Supplies/Toys",
  "Doors & Gates>Pet Doors " => "Cat Supplies/Doors & Gates",
  "Doors & Gates>Replacement Flaps " => "Cat Supplies/Doors & Gates",
  "Toys>Laser Toys " => "Cat Supplies/Toys",
  "Toys>Balls & Tracks " => "Cat Supplies/Toys",
  "Cages & Carriers>Soft-Sided Carriers " => "Cat Supplies/Cages & Carriers",
  "Cat Food>Adult Cat " => "Cat Supplies/Cat Food",
  "Flea & Tick Treatments>Flea & Tick Powders & Sprays " => "Cat Supplies/Flea & Tick ",
  "Flea & Tick Treatments>Flea & Tick Shampoo " => "Cat Supplies/Flea & Tick ",
  "Cat Food>Non-Domestic (Exotic) " => "Cat Supplies/Cat Food",
  "Cages & Carriers>Playpens " => "Cat Supplies/Cages & Carriers",
  "Health Care, Supplements & Nutrition>Urinary Tract Care " => "Cat Supplies/Health Care Supplies",
  "Substrate & Scoops>Bark & Walnut Shell " => "Reptile Services & Supplies/Substrates and Such",
  "Lighting>Light Fixtures " => " Reptile Services & Supplies/Lighting",
  "Food>Turtle & Tortoise Food " => " Reptile Services & Supplies/Food",
  "Cages, Terrariums & Stands>Wire & Screen Cages " => "Reptile Services & Supplies/Cages & Terrariums",
  "Cages, Terrariums & Stands>Screen Covers " => "Reptile Services & Supplies/Cages & Terrariums",
  "Temperature Control>Heat Lamps & Reflectors " => "Reptile Services & Supplies/Temperature Control",
  "Lighting>Fluorescent Lights " => "Reptile Services & Supplies/Lighting",
  "Lighting>Halogen Lamps " => "Reptile Services & Supplies/Lighting",
  "Lighting>Black Lights & Specialty " => "Reptile Services & Supplies/Lighting",
  "Lighting>Spot & Heat Lamps " => "Reptile Services & Supplies/Lighting",
  "Temperature Control>Heat Emitters " => "Reptile Services & Supplies/Temperature Control",
  "Lighting>Surge Protectors & Timers " => "Reptile Services & Supplies/Lighting",
  "Temperature Control>Thermometers & Hygrometers " => "Reptile Services & Supplies/Temperature Control",
  "Cage & Terrarium Accessories>Turtle Docks, Ramps & Logs " => "Reptile Services & Supplies/Cage Accessories",
  "Bowls, Feeders & Waterers>Bowls & Crocks " => "Reptile Services & Supplies/Feeders & Waterers",
  "Cage & Terrarium Accessories>Wood, Rocks, Plants & Decor " => "Reptile Services & Supplies/Cage Accessories",
  "Food>Bearded Dragon Food " => "Reptile Services & Supplies/Food",
  "Food>Iguana Food " => "Reptile Services & Supplies/Food",
  "Food>Cricket Food & Gut Load " => "Reptile Services & Supplies/Food",
  "Health Care, Supplements & Nutrition>Shedding & Mites " => "Reptile Services & Supplies/Health Care Supplies",
  "Health Care, Supplements & Nutrition>Vitamins & Calcium " => "Reptile Services & Supplies/Health Care Supplies",
  "Cleaning, Sanitation & Handling>Sifters & Scoops " => "Reptile Services & Supplies/Cleaning & Sanitation",
  "Cleaning, Sanitation & Handling>Cage & Terrarium Cleaners " => "Reptile Services & Supplies/Cleaning & Sanitation",
  "Substrate & Scoops>Moss " => "Reptile Services & Supplies/Substrates and Such",
  "Substrate & Scoops>Cage Liners " => "Reptile Services & Supplies/Substrates and Such",
  "Bowls, Feeders & Waterers>Feeders & Waterers " => "Reptile Services & Supplies/Feeders & Waterers",
  "Food>Gecko Food " => "Reptile Services & Supplies/Food",
  "Health Care, Supplements & Nutrition>Eye Drops " => "Reptile Services & Supplies/Health Care Supplies",
  "Cages, Terrariums & Stands>Plastic Terrariums " => "Reptile Services & Supplies/Cages & Terrariums",
  "Cage & Terrarium Accessories>Hermit Crab Care Supplies " => "Reptile Services & Supplies/Cage Accessories",
  "Terrarium Pumps & Filters>Turtle Filters " => "Reptile Services & Supplies/Filters & Pumps",
  "Terrarium Pumps & Filters>Filter Media " => "Reptile Services & Supplies/Filters & Pumps",
  "Terrarium Pumps & Filters>Internal Filters " => "Reptile Services & Supplies/Filters & Pumps",
  "Temperature Control>Under Tank Heaters & Cables " => "Reptile Services & Supplies/Temperature Control",
  "Food>Mealworms, Bites, Quenchers & Fruits " => "Reptile Services & Supplies/Food",
  "Food>Hermit Crab Food " => "Reptile Services & Supplies/Food",
  "Cleaning, Sanitation & Handling>Gloves, Hooks & Hand Sanitizers " => "Reptile Services & Supplies/Cleaning & Sanitation",
  "Cage & Terrarium Accessories>Liners & Backgrounds " => "Reptile Services & Supplies/Cage Accessories",
  "Substrate & Scoops>Reptile Sand " => "Reptile Services & Supplies/Substrates and Such",
  "Health Care, Supplements & Nutrition>Turtle Health Care " => "Reptile Services & Supplies/Health Care Supplies",
  "Cleaning, Sanitation & Handling>Water Clarifiers & Plant Cleaners " => "Reptile Services & Supplies/Cleaning & Sanitation",
  "Humidity Control>Cage Misters " => "Reptile Services & Supplies/Humidity Control",
  "Food>Amphibian Food " => "Reptile Services & Supplies/Food",
  "Miscellaneous " => "Reptile Services & Supplies/Everything Else",
  "Travel & Outdoors>Car Barriers & Protectors " => "Dog Supplies/Travel & Outdoors",
  "Travel & Outdoors>Car Harnesses " => "Dog Supplies/Travel & Outdoors",
  "Travel & Outdoors>Carriers & Dog Purses " => "Dog Supplies/Travel & Outdoors",
  "Travel & Outdoors>Travel & Outdoor Beds " => "Dog Supplies/Travel & Outdoors",
  "Books & Videos>Saltwater>Saltwater Books " => "Aquarium & Pond Supplies/Everything Else" }

    CSV.foreach("#{Rails.root}/public/uploads/#{file}", :col_sep=>'|', :quote_char => '|',headers: true) do |row|
        # if row["category"] == "Dog Supplies "
        #   category = Category.where(url: "dog-products1").first
        # elsif row["category"] == "Aquarium Supplies " || row["category"] == "Pond Supplies "
        #   category = Category.where(url: "fish-products").first
        # elsif row["category"] == "Cat Supplies "
        #   category = Category.where(url: "cat-products").first
        # elsif row["category"] == "Reptile Supplies "
        #   category = Category.where(url: "reptile-products").first
        # elsif row["category"] == "Small Animal Supplies "
        #   category = Category.where(url: "small-pet-products").first
        # elsif row["category"] == "Bird Supplies "
        #   category = Category.where(url: "bird-products").first
        # end
       if row["subcategory"].present?
          category_val = total_categories.select{ |k,v| k.downcase.delete(' ').eql?(row["subcategory"].downcase.delete(' '))} 
          if category_val.present?
            category_name = category_val.values.first.split('/').first.downcase.delete(' ')
            subcategory_name = category_val.values.first.split('/').second.downcase.delete(' ')
            category = Category.select{|c| c.display_name(I18n.locale).downcase.delete(' ') == category_name}
            if category.present?
              subcategory = category.first.subcategories.select{|x| x.display_name(I18n.locale).downcase.delete(' ') == subcategory_name}
              if subcategory.present?
                subcategory = subcategory.first.id
              end
            end
          end
        end
        if subcategory.present?
          listing_uuid = UUIDUtils.create_raw
          price = (row["price"].to_f*100).round
          listing_hash = {community_id: 1, uuid: listing_uuid, author_id: @author, title: row["title"], description: row["description"], origin: row["location"], category_id: subcategory,listing_shape_id: 3, transaction_process_id:1, price_cents: price, currency: "USD", require_shipping_address: true, shipping_price_cents: 0, shape_name_tr_key: "0c4ba7ae-0f9c-4a60-a115-0bccb435e1bf", 
            action_button_tr_key: "f41d86b8-3271-4670-bf3e-fb8582e355a0"}
          listing = Listing.where(title: listing_hash[:title])
          if listing.count >= 1 
            listing.first.update_attributes(listing_hash)
          # else
          #   listing = Listing.create!(listing_hash)
          #     if row["product_images"].present?
          #       listing_image = ListingImage.new(listing_id: listing.id, author_id: @author, image_content_type: "image/jpeg", image_downloaded: true) 
          #       encoded_url = URI.encode(row["product_images"])
          #       listing_image.image = URI.parse(encoded_url)
          #       listing_image.save!
          #     end
          end
        end
    end
  end

end