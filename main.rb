# 
# COPYRIGHT LESTER COVEY,
#
# 2022

def main
	require 'net/http'
	require 'uri'
	require 'json'

	CACHE_FILE_NAME = "#{__dir__}/bruh_cache.bin"
	SHELL_COMMAND = "sudo report \"BRUH: "

	uri = URI.parse("https://www.mos.ru/pgu/ru/application/dogm/040201/")
	request = Net::HTTP::Post.new(uri)
	request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
	request["Accept"] = "application/json, text/javascript, */*; q=0.01"
	request["Accept-Language"] = "ru"
	request["Host"] = "www.mos.ru"
	request["Origin"] = "https://www.mos.ru"
	request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15"
	request["Connection"] = "keep-alive"
	request["Referer"] = "https://www.mos.ru/pgu/ru/application/dogm/040201/"
	request["Content-Length"] = "57"
	request["Cookie"] = "*"
	request["X-Requested-With"] = "XMLHttpRequest"
	request.set_form_data(
		"ajaxAction" => "give_data",
		"ajaxModule" => "Ege",
		"ajax_app_id" => "257171651",
	)

	req_options = {
		use_ssl: uri.scheme == "https",
	}

	$verbose = ARGV.include?('-V')

	def report(message)
		system("#{SHELL_COMMAND} #{message}\"")
	end

	def terminate_with(message)
		if $verbose then
			puts message
		else
			report message
		end
		exit 1
	end

	def digResult(from)
		from.each do |i|
			next unless i['name'] == 'score'
			return i['value']
		end
	end

	response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		http.request(request)
	end

	terminate_with "Got #{response.code} response code, terminating..." if response.code != '200'

	begin
		parsed = JSON.parse(response.body)
		parsed['data']['CoordinateStatusDataMessage']['Documents']['ServiceDocument']['CustomAttributes']['examResultList']['examResult'].each do |i|
			puts "#{i['subjectName']} – #{digResult(i['resultPart'])}"
		end
	rescue
		terminate_with "Got invalid JSON, terminating..."
	end
end