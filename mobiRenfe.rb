require "selenium-webdriver"
require 'moped'

#Connect with DB
session = Moped::Session.new([ "127.0.0.1:27017" ])
session.use "renfe_vizz"

@driver = Selenium::WebDriver.for :firefox
@base_url = "http://renfe.mobi"
@accept_next_alert = true
@driver.manage.timeouts.implicit_wait = 30
@verification_errors = []

@driver.get(@base_url + "/renfev2/busca_trenes.do;jsessionid=FF8ECCC7F2B53A47187445D06C1AF1A9?ss=FF8ECCC7F2B53A47187445D06C1AF1A9&ga=true")



o = "Sevilla"
d = "Granada"

@driver.find_element(:name, "o").send_keys o
@driver.find_element(:name, "d").send_keys d
@driver.find_element(:name, "DF").send_keys "11"
@driver.find_element(:name, "MF").send_keys "Julio"
@driver.find_element(:name, "AF").send_keys "2013"
@driver.find_element(:name, "horario").click

# wait for the result
wait = Selenium::WebDriver::Wait.new(:timeout => 10)

#Get All trains for a trip
@allTrains
@trains= Hash.new

wait.until {

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

  @allTrains if @allTrains.length > 0
}

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

@driver.navigate.back

#@driver.quit