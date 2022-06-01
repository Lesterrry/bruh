# 
# COPYRIGHT LESTER COVEY,
#
# 2022

require_relative "bruh/version"
require_relative "bruh/internal"
require_relative "../config"
require 'net/http'
require 'uri'
require 'json'
require 'mosru'
require 'pathname'

module Bruh

	class Error < StandardError; end

	class Result
		attr_reader :exam, :score, :id
		def initialize(exam, score, id)
			@exam = exam
			@score = score
			@id = id
		end
	end

	def self.update_cookies
		p = Pathname.new(Config.cookie_file_location)
		if not p.writable? and p.exist? then 
			Internal.terminate_with "Cookie file not writable, terminating...", $verbose
		end
		begin
			cookies = Mosru::Auth.perform(Config.mosru_login, Config.mosru_password, $verbose)
			cookies.bury(Config.cookie_file_location)
			$jar = cookies
		rescue Exception => e
			Internal.terminate_with "Unable to fetch cookies (#{e}), terminating...", $verbose
		end
	end

	def self.main
		$verbose = ARGV.include?('-V')
		$jar = Hash.new
		$results = []
		attempt_two = false
		loop do
			if attempt_two
				update_cookies
			elsif File.file?(Config.cookie_file_location) then
				$jar = Mosru::Auth::CookieJar.new()
				$jar.restore(Config.cookie_file_location)
				puts "Using saved cookies..." if $verbose
			else 
				puts "No cookies found, fetching new..." if $verbose
				update_cookies
			end
			puts "Fetching form hash..." if $verbose
			form_hash = Internal.get_form_hash($jar)
			if form_hash.nil?
				puts "The cookies are probably outdated, fetching new..." if $verbose
				attempt_two = true
				next
			end
			puts form_hash.inspect if $verbose
			puts "Fetching app id..." if $verbose
			app_id = Internal.get_app_id(form_hash, Config.reg_code, Config.id_num, $jar)
			if app_id.nil?
				Internal.terminate_with "App ID request failed, terminating...", $verbose
			end
			puts app_id.inspect if $verbose if $verbose
			puts "Fetching exams results..." if $verbose
			parsed = Internal.get_ege_data(app_id, $jar)
			if parsed.nil?
				Internal.terminate_with "EGE results request failed, terminating...", $verbose
			end
			parsed.each do |i|
				result = Result.new(i['subjectName'], Internal.dig_result(i['resultPart']), i['id'])
				$results << result
			end
			if File.file?(Config.cache_file_location) then
				file = File.read(Config.cache_file_location)
				cached = Marshal.load(file)
				updated = $results.select{ |i| cached.find{ |j| j.id == i.id } == nil }
			else 
				updated = $results
			end
			if updated.length > 0 then
				s = "New results:"
				div = "\n"
				updated.each do |i|
					s += "#{div}#{i.exam} – #{i.score}"
				end
				if $verbose
					puts s
				else
					Internal.report s
				end
			elsif $verbose
				puts "Nothing"
			end
			begin
				file = File.new(Config.cache_file_location, 'w')
				file.puts(Marshal.dump($results))
			rescue
				terminate_with "Unable to write to file, terminating...", $verbose
			end
			break
		end
	end

end
