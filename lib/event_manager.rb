require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_numbers(number)
  # if length is less than 10, return bad number string
  # if the length is 10, assume it is good
  # If the number is 11 digitss
    # if the first number is 1, trim 1 and use the rest of the digits
    # if the first number is not 1, return bad number
  # if number length is > 11, assume bad number

  if number.length == 10
    return number.to_i
  elsif number.length == 11 && number[0] == '1'
      return number[1..].to_i
  end
  'Bad Number'
  
end

def hour_registered(timeframe)
  space = timeframe.index(" ")
  hour = timeframe[space+1, space+3].to_i
  hour
end
  

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_manager/event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('event_manager/form_letter.erb')
erb_template = ERB.new template_letter

all_registered_hours = []
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone_numbers(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  registered_hour = hour_registered(row[:regdate])
  all_registered_hours << registered_hour
  


  form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
end


