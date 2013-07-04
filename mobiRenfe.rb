require "selenium-webdriver"
require 'moped'
require "json"

# ----------------------------------------------------------------
# Webdriver Settings for Renfe Scrapper - by Victoriano Izquierdo
#-----------------------------------------------------------------

#Connect with MongoDB
session = Moped::Session.new([ "127.0.0.1:27017" ])
session.use "renfe_vizz"
#Writes to journeys collection in the MongoDB
journeys = session[:new_collection]

@driver = Selenium::WebDriver.for :firefox
@base_url = "http://renfe.mobi"
@driver.manage.timeouts.implicit_wait = 5


# ----------------------------------------------
# Retrieve List of all cities train stations 
#-----------------------------------------------

@driver.get(@base_url + "/renfev2/busca_trenes.do")

all_cities = @driver.find_element(:name, "o").find_elements(:tag_name, "option")

#Clean array of cities from objects to strings
for i in (1).upto(all_cities.length-1)
  all_cities[i-1] = all_cities[i].text
end

#Check sanity of the new array
@counter = 0
for i in (0).upto(all_cities.length-2)
  for j in (0).upto(all_cities.length-2)

    puts "I: #{i} J: #{j}"  
    puts "Departure is: " + all_cities[i]
    puts "Arrival is: " + all_cities[j]
    puts "..............................."
    @counter = @counter + 1
    puts @counter
  end
end

# ------------------------------------------------
# Utility Methods for interaction with renfe.mobi
#-------------------------------------------------

# Returns a webpage with a query for a journey between two cities
def queryJourney(o, d)

  #@driver.get(@base_url + "/renfev2/detalle_precio.do?ss=E&des=&num=&mes=&dia=&anyo=&ori=")
  @driver.get(@base_url + "/renfev2/busca_trenes.do")

   #Rerequest page until page is not down 
   while @driver.find_element(:xpath, "html/body/h1").text == "Estado HTTP 500 -" 
       puts "Renfe is down!"
       @driver.get(@base_url + "/renfev2/busca_trenes.do")
   end

  # waiter for the result
  #wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  #wait.until { @driver.find_element(:name, "d").displayed?}

   @driver.find_element(:name, "o").send_keys o
   @driver.find_element(:name, "d").send_keys d
   @driver.find_element(:name, "DF").send_keys "10"
   @driver.find_element(:name, "MF").send_keys "Julio"
   @driver.find_element(:name, "AF").send_keys "2013"
 
   @driver.find_element(:name, "horario").click

 end

#Returns true for pages with no trains between a valid combinations of cities
def noTrains?
  return @driver.find_elements(:xpath, ".//*[@id='details']/p/a").size()>0
end

#Returns true for pages with trains between cities
def pageWithResults?
  return @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[*]/li[1]/a").any?
end

# Returns true for error pages
def errorPage?
  @driver.find_elements(:xpath, ".//*[@id='resultados']/ul").size()==0 and 
  @driver.find_elements(:xpath, ".//*[@id='details']/p").first.text=="No ha introducido ciudad de origen o destino" or
  @driver.find_elements(:xpath, ".//*[@id='details']/p").first.text=="La fecha introducida no es correcta"
end


# ----------------------------------------------
# Iterate through all the combination of Cities
#-----------------------------------------------

for i in (96).upto(all_cities.length-2)
  for j in (73).upto(all_cities.length-2)

    o = all_cities[i]
    d = all_cities[j]

    puts "....................>"
    puts "Departure is: " + o
    puts "Arrival is: " + d

    queryJourney(o, d)
    puts "//// queried with I: #{i} J: #{j}"

  # ** Case no trains for these cities **
  if noTrains?
    puts " --- No trayecto para I: #{i} J: #{j} ---"  
    next
  end

  # ** Case error page with no cities ** 
  # when Firefox windows is not active 
  if errorPage?

    puts " --- Web vacia with no cities passed for: #{i} J: #{j} --- "  
    
    #query the journey until it does not get a non-valid page,
    while errorPage? 

     queryJourney(o, d)
     puts "**** re-queried with I: #{i} J: #{j}"
   end

   puts "Web with results or no combination shown now" 

    #Notrains? keep iterating to next cities
    if noTrains?
     next
   end

 end

 # ** Case is combination of cities joined by trains ** 

    # wait for the results
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)

    #Check if this current page contains results before retrieving any of them
    @allTrains = wait.until {
      els = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[*]/li[1]/a")
      if els.any?
        puts "Web con results I: #{i} J: #{j}" 
      end    
      els if els.any?
    }

   #Store all the trains for this valid journey in this hash
   @trains= Hash.new

   #parse type of train, schedule, time travel
   for z in (@allTrains.length).downto(1)
     @tname = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[#{z}]/li[1]/a")
     puts @tname.first.text
     @trains[[z,0]]= @tname.first.text
     @departure = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[#{z}]/li[2]")
     puts @departure.first.text.split[1]
     @trains[[z,1]]= @departure.first.text.split[1]
     @arrival = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[#{z}]/li[3]")
     puts @arrival.first.text.split[1]
     @trains[[z,2]] = @arrival.first.text.split[1]
     @duration = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[#{z}]/li[4]")
     hours = @duration.first.text.split[1]
     mins = @duration.first.text.split[3]
     ttime = hours.to_i*60 + mins.to_i
     puts ttime
     @trains[[z,3]]= ttime
   end

#Add to DB general data of this Journey
#db.connections.find({oCity: "A Coruña"}, {_id: 0, ntrains: 1})
#prev_ntrains = journeys.find(oCity: o).select(ntrains: 1).first
#parsed = JSON.parse(prev_ntrains) prev_ntrains["ntrains"].to_i 
#puts prev_ntrains

ttrains = @allTrains.length 
#Add to DB every Train for this Journey
for k in (@allTrains.length).downto(1)
  puts "t#{i}#{j}#{k}_to"
  journeys.find(oCity: o).upsert({"$addToSet" => { "trains" => {"oCity" => o, "t#{i}#{j}-#{k}_to" => d, "t#{i}#{j}-#{k}_ref" => @trains[[k,0]], 
    "t#{i}#{j}-#{k}_dep" => @trains[[k,1]], "t#{i}#{j}-#{k}_arriv" => @trains[[k,2]], "t#{i}#{j}-#{k}_time" => @trains[[k,3]]}}})
  
end

journeys.find(oCity: o).update({ "$inc" =>{ "trains_out" => @allTrains.length}})

puts "Total trains #{@allTrains.length}"
puts "Total journeys in DB #{journeys.find.count}"

end 
end  

#@driver.navigate.back
#@driver.quit