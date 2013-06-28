require "selenium-webdriver"
require 'moped'

#Connect with DB
session = Moped::Session.new([ "127.0.0.1:27017" ])
session.use "renfe_vizz"

@driver = Selenium::WebDriver.for :firefox
@base_url = "http://renfe.mobi"
@accept_next_alert = true
@driver.manage.timeouts.implicit_wait = 5
@verification_errors = []

@driver.get(@base_url + "/renfev2/busca_trenes.do")

all_cities = @driver.find_element(:name, "o").find_elements(:tag_name, "option")

#Clean array of cities from objects to strings
for i in (1).upto(all_cities.length-1)
  all_cities[i-1] = all_cities[i].text
end

@counter = 0;

#Check sanity of the new array
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

#Iterate all the combination of Cities

for i in (0).upto(all_cities.length-2)
  for j in (0).upto(all_cities.length-2)

    @driver.navigate.back

    o = all_cities[i]
    d = all_cities[j]

    puts "Departure is: " + o
    puts "Arrival is: " + d

    @driver.find_element(:name, "o").send_keys o
    @driver.find_element(:name, "d").send_keys d
    @driver.find_element(:name, "DF").send_keys "11"
    @driver.find_element(:name, "MF").send_keys "Julio"
    @driver.find_element(:name, "AF").send_keys "2013"
    @driver.find_element(:name, "horario").click

    # wait for the result
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)

   #puts @driver.find_elements(:xpath, ".//*[@id='resultados']/ul").size()
   
   #Journey does exist?
   if @driver.find_elements(:xpath, ".//*[@id='details']/p/a").size()>0
    next
  end

  #Journey does exist?
  if @driver.find_elements(:xpath, ".//*[@id='resultados']/ul").size()==0
    next
  end
  
   #Get All trains for a trip
   @trains= Hash.new

   @allTrains = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[*]/li[1]/a")

   #parse type of train, schedule, time travel
   for i in (@allTrains.length).downto(1)
     @tname = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[#{i}]/li[1]/a")
     puts @tname.first.text
     @trains[[i,0]]= @tname.first.text
     @departure = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[#{i}]/li[2]")
     puts @departure.first.text.split[1]
     @trains[[i,1]]= @departure.first.text.split[1]
     @arrival = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[#{i}]/li[3]")
     puts @arrival.first.text.split[1]
     @trains[[i,2]] = @arrival.first.text.split[1]
     @duration = @driver.find_elements(:xpath, ".//*[@id='resultados']/ul[#{i}]/li[4]")
     hours = @duration.first.text.split[1]
     mins = @duration.first.text.split[3]
     ttime = hours.to_i*60 + mins.to_i
     puts ttime
     @trains[[i,3]]= ttime
   end


#Writes in the DB
journeys = session[:journeys]

#Add to DB general data of this Journey
journeys.insert( oCity: o, dCity: d, ntrains: @allTrains.length);

#Add to DB every Train for this Journey
for i in (@allTrains.length).downto(1)
  journeys.find(oCity: o, dCity: d).update("$addToSet" => { "trains" => { "tname" => @trains[[i,0]], 
    "departure" => @trains[[i,1]], "arrival" => @trains[[i,2]], "duration" => @trains[[i,3]]}});
end

puts "Total trains #{@allTrains.length}"
puts "Total journeys in DB #{journeys.find.count}"


end 
end  

#@driver.navigate.back
#@driver.quit