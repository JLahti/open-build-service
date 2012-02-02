#!/usr/bin/env ruby
require 'rubygems'
require 'headless'
require 'colored'
require 'net/http'

#$DEBUG = 1;

def distribute(*args)
  length = args.pop
  sum = args.reduce(:+).to_f
  i=0; args.collect! { |e| i+=1; [i, e, length*(e/sum)] }
  err = args.collect { |e| e[2].modulo(1) }.reduce(:+).round
  args.collect! do |e|
    if e[1].nonzero? and e[2] < 1 then
      err -= 1
      [ e[0], e[1], 1 ]
    else e
    end
  end
  if err > 0 then
    args.sort! { |a,b| b[2].modulo(1) <=> a[2].modulo(1) }.collect! do |e|
      if err.nonzero? then err -= 1; [ e[0], e[1], e[2].floor + 1 ] 
      else [ e[0], e[1], e[2].floor ] end
    end
  elsif err < 0 then
    args.sort! { |a,b| a[2].modulo(1) <=> b[2].modulo(1) }.collect! do |e|
      if err.nonzero? and e[2].floor > 1 then err += 1; [ e[0], e[1], e[2].floor - 1 ]  
      else [ e[0], e[1], e[2].floor ] end
    end
  end
  args.sort_by { |e| e[0] }.collect { |e| e[2] }
end



# require all libs and test cases
require File.expand_path File.dirname(__FILE__) + '/lib/AcceptanceTest.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC01__Login.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC02__Home.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC03__CreateProject.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC04__EditProject.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC05__AddProjectAttributes.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC06__DeleteProjectAttributes.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC07__CreatePackage.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC08__AddPackageSources.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC09__EditPackageSources.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC10__BranchPackage.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC11__EditPackage.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC12__AddPackageAttributes.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC13__DeletePackageAttributes.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC14__Search.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC15__AllProjectsList.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC16__AddProjectUsers.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC17__EditProjectUsers.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC18__AddPackageUsers.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC19__EditPackageUsers.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC20__DeletePackage.rb'
require File.expand_path File.dirname(__FILE__) + '/tests/TC21__DeleteProject.rb'


# Setup all global settings
$data = Hash.new
$data[:report_path] = ENV["OBS_REPORT_DIR"] || 'results' + Time.now.strftime("AcceptanceTest__%m-%d-%Y/")

PORT=3199
webui_out = nil
frontend = Thread.new do
  puts "Starting test webui at port #{PORT} ..."
  webui_out = IO.popen("cd ../webui; exec ./script/server -e test -p #{PORT} 2>&1")
  puts "Webui started with PID: #{webui_out.pid}"
  begin
    Process.setpgid webui_out.pid, 0
  rescue Errno::EACCES
    # what to do?
    puts "Could not set group to root"
  end
  while webui_out
    begin
      line = webui_out.gets
    rescue IOError
      break
    end
  end
end

while true
  puts "Waiting for Webui to serve requests..."
  begin
    Net::HTTP.start("localhost", PORT) do |http|
      http.open_timeout = 15
      http.read_timeout = 15
      res = http.get('/')
      case res
        when Net::HTTPSuccess, Net::HTTPRedirection, Net::HTTPUnauthorized
          # OK
        else
          puts "Webui did not response nicely"
          Process.kill "INT", -webui_out.pid
          webui_out.close
          webui_out = nil
          frontend.join
          exit 1
      end
    end
  rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, Timeout::Error
    sleep 1
    next
  end
  break
end

puts "Webui ready"
$data[:url] = "http://localhost:#{PORT}"
$data[:asserts_timeout] = 5
$data[:actions_timeout] = 5

for i in 1..9 do
  $data["user#{i}".to_sym]                    = Hash.new
  $data["user#{i}".to_sym][:login]            = "user#{i}"
  $data["user#{i}".to_sym][:password]         = "123456"
  $data["user#{i}".to_sym][:created_projects] = Array.new
end

$data[:admin] = Hash.new
$data[:admin][:login] = 'king'
$data[:admin][:password] = 'sunflower'
$data[:admin][:created_projects] = Array.new

$data[:invalid_user] = Hash.new
$data[:invalid_user][:login] = 'dasdasd'
$data[:invalid_user][:password] = 'dasdsad'


# Prepare folders and variables needed for the run
Dir.mkdir $data[:report_path]
report = HtmlReport.new
fail_details = String.new
passed  = 0
failed  = 0
skipped = 0
TestRunner.add_all
#TestRunner.set_limitto ["wrong_number_of_values_for_package_attribute", "search_for_home_projects"]

# Run the test
display = Headless.new
display.start
$page = WebPage.new WebDriver.for :firefox #, :remote , "http://localhost:5910'
time_started = Time.now
TestRunner.run do |test|
  if test.status == :ready then
    print((test.name.to_s+"                                               ")[0,55])
    STDOUT.flush
  else
    puts case(test.status)
      when :pass then
        passed += 1
        test.status.to_s.bold.green
      when :fail then 
        failed += 1
        fail_details += "\n#{failed}) #{test.name}:\n#{test.message}".red
        test.status.to_s.bold.red
      when :skip then
        skipped += 1
        test.status.to_s.bold.blue
      when :rescheduled then
        test.status.to_s.bold.green
      else
        raise 'Invalid status value!'
    end
    report.add test unless test.status == :rescheduled
  end
end
time_ended = Time.now
$page.close
display.destroy

# Put success rate statistics
lp, lf, ls = distribute passed, failed, skipped, 59
puts  ("_"*59)
print ("_"*lp).on_green
print ("_"*lf).on_red
puts  ("_"*ls).on_blue
puts ""
print "     " + "#{passed} passed".bold.green  + "       "
print           "#{failed} failed".bold.red    + "       "
puts            "#{skipped} skipped".bold.blue

# Put time statistics
duration = time_ended - time_started
if duration.div(60) > 0 then
  total_duration  = "Total duration:  #{duration.div(60)} minutes"
  total_duration += " and #{duration % 60} seconds" if duration % 60 > 0
else
  total_duration  = "Total duration:  #{duration} seconds"
end
puts "Test started at: #{time_started.to_s}"
puts "Test ended at:   #{time_ended.to_s}"
puts total_duration
puts ""

# Save report and display details
report.save $data[:report_path] + "report.html"
puts fail_details unless ARGV.include? "--no-details"
gets if ARGV.include? "--pause-on-exit"

puts "kill #{webui_out.pid}"
Process.kill "INT", -webui_out.pid

webui_out.close
webui_out = nil
frontend.join

