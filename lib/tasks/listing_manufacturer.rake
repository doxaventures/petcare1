namespace :listing_manufacturer do
  desc "Populate the listing manufacturer data"
  task :manu_feed => :environment do
	@manu = ["Homemade","Carolina Prime Pet Inc.","Nootie","Quaker Pet Group","Thundershirt","Cobalt Aquatics","Cloudy Star Corporation","Fresh News (BPV Environmental)","Electric Cleaner Co.","Emerald Pet Products","Pet Matrix","John Paul Products","Cleanicity (Stikitty)","SuperPads","Supreme Petfoods Limited","Pure Pets Aquatic","Bionic Pet Products","think!dog Treats (Delca Corporation)","Fetch for Pets","The Missing Link (Designing Health)","Sojos","Carefresh","Aquarium Pharmaceuticals, API, MARS Fishcare","Pondcare, MARS Pondcare","Marineland","Instant Ocean","Bramton, Simple Solution","Bio-Groom (Bio-Derm Laboratories)","Binghamton Knitting Co.","Pretty Bird International, Pretty Pets","Cardinal Pet Laboratories","Sergeant`s/Sentry","Lambert Kay","Coastal Pet","Carlson Pet Products","Mendota Products Inc.","CaribSea","The Clorox Company","Charming","Double K Industries","Hurricane","Dainichi","Andis USA","Petmate (Doskocil)","Danner Mfg.","Dingo Brand","Dogswell/Catswell","Perfecto Manufacturing","Estes Gravel","Eight in One (8 in 1)","Natures Miracle Products","Coralife","Zilla Reptile","Ethical/Spot","First Nature","Fluker Farms","Farnam","Fivestarpet","Four Paws","Fibrecycle Usa Inc.","Golden Farm Products","Gamma Plastics Vittles","Gulf Coast Nutritionals/Ark Naturals","Petstages","Gimborn","Chuckit! (Canine Hardware)","Higgins Pet Food","Hunter Mfg.","Sherpa Pet Carriers","Ani Mate Inc/Pet Mate","Super Pet/Pets International","Angels` Eyes / I`m a Little Teacup, Inc","Conair Corp.","Antler`s Unlimited","Bingo","Jungle Talk","Jungle Labs (Jungle Laboratories)","JW Pet Company","Quality One Items Inc. (Insta Pet)","Pure Treats Inc. (PureBites)","Synergy Labs","Kordon/Novalek/Oasis","Koller Pet Group","Smokehouse Pet Products","Pet Tek","Kent Marine","Kollercraft Pet Products","Kaytee Products","LM Animal Farms","Lafeber","Lee`s Aquarium & Pet Products","Lennox International Inc","Loving Pets, Corp.","Lixit","Lion Ribbon Co.","Cosmic Pet","Merrick Pet Care","Marshall Pet Products","Multipet International","Midwest Metal Products Co. (Midwest Homes)","Mammoth Pet Products","Zoo Med","Nature Labs","ZuPreem","Fancy Feast","Pro Plan","Friskies","Tidy Cat","Scamp","Natural Balance Pet Food","Natural Polymer International","Natural Chemistry","Nature`s Earth Products","Nutri-Vet","TropiClean","Oceanic Systems Inc.","Tom Aquatics","Company of Animals","Old Mother Hubbard/Wellness","Vetericyn","J.J. Fuds","Our Pets Company","Petcetera, Inc.","PetStore.com House Brands","PetAg","Q T Dog, LLC (Antlerz)","Eagle Pack/WellPet/Holistic","Eshopps","New Age Pet (Eco-Concepts)","Aquatrol","Fe-Lines, Inc. (Sticky Paws)","Canidae Pet Foods","Lifegard Aquatics","Redbarn Premium Pet Products","Rep-Cal","Ryans Pet Supplies","Roudybush","Diamond Pet Foods","PetSafe/Radio Systems Corporation","San Francisco Bay Brand","Seachem","Pet Silk, Inc.","Greenies","PSI (Pet Supply Imports)","Sun Seed","Salix","T.H.E. Laboratories","T.F.H. Nylabone","Kong","Tetra (TetraPond)","Tomlyn","HomeoPet","Kurgo","United Valley Pet Food","FURminator","American Colloid Company (Premium Choice)","Arm & Hammer","Virbac Animal Health","Metropolitan Vacuum Cleaners","Prevue-Hendryx","Hartz Mountain Corp.","Ware Manufacturing","Triple Crown/StarMark","Wardley Products","Zodiac Pet Care Products","Zuke`s","Aqueon","Clevercat Innovations","Drinkwell"]
    @manu.each do |manu|
      Manufacturer.find_or_create_by(name: manu)
    end
  end
end


