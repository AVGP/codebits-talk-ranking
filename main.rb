require "rubygems"
require "mechanize"

EMAIL    = "your.email@example.com"
PASSWORD = "yourPassw0rd"

agent = Mechanize.new
agent.idle_timeout = 60

puts "Loading..."
agent.get("https://codebits.eu/login/") do |page|
  intranet = page.form_with(action: "/op/login/") do |form|
    puts "Logging in..."
    form.mail     = EMAIL
    form.password = PASSWORD
  end.click_button
  
  puts "Loading talks..."
  
  talks = {}
  talks_list = agent.click(intranet.link_with(text: "Call for talks"))
  talks_list.search("h4 a").each do |talk|
    talk_details = agent.click(talks_list.link_with(text: talk.text))
    talks[talk.text] = talk_details.search("#rateup").text.to_i
  end
  
  talks = talks.sort_by { |title, score| score }
  
  talks.reverse.each_with_index do |talk, i|
    puts " > #{i+1} #{talk[1]} - #{talk[0]}" 
  end
end