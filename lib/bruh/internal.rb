# 
# COPYRIGHT LESTER COVEY,
#
# 2022

module Bruh

	class Internal
		def self.report(message)
			system("#{Config.shell_command} #{message}\"")
		end
		def self.terminate_with(message, verbose)
			if verbose then
				puts message
			else
				report message
			end
			exit 1
		end
		def self.dig_result(from)
			from.each do |i|
				next unless i['name'] == 'score'
				return i['value']
			end
		end
		def self.get_form_hash(cookie_jar)
			uri = URI.parse("https://www.mos.ru/pgu/ru/application/dogm/040201/#step_2")
			request = Net::HTTP::Get.new(uri)
			request["Cookie"] = cookie_jar.plain
			request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
			request["Host"] = "www.mos.ru"
			request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15"
			request["Accept-Language"] = "ru"
			request["Referer"] = "https://login.mos.ru/"
			request["Connection"] = "keep-alive"
			req_options = { use_ssl: uri.scheme == "https" }
			response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
				http.request(request)
			end
			return nil if response.code != '200'
			txt = response.body.split('FormHash" value="')[1]
			txt = txt.split('"/>')[0]
			return txt
		end
		def self.get_app_id(form_hash, reg_code, id_num, cookie_jar)
			uri = URI.parse("https://www.mos.ru/pgu/ru/application/dogm/040201/#step_2")
			request = Net::HTTP::Post.new(uri)
			request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
			request["Accept"] = "*/*"
			request["Accept-Language"] = "ru"
			request["Host"] = "www.mos.ru"
			request["Origin"] = "https://www.mos.ru"
			request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15"
			request["Connection"] = "keep-alive"
			request["Referer"] = "https://www.mos.ru/pgu/ru/application/dogm/040201/"
			# request["Content-Length"] = "7192"
			request["Cookie"] = cookie_jar.plain
			request["X-Requested-With"] = "XMLHttpRequest"
			request.set_form_data(
				"action" => "send",
				"comment" => "",
				"field[new_sh2_person2_login1]" => reg_code,
				"field[new_sh2_person2_password1]" => id_num,
				"form_id" => "040201",
				"org_id" => "dogm",
				"send_from_step" => "1",
				"total" => "2",
				"uniqueFormHash" => form_hash,
			)
			req_options = { use_ssl: uri.scheme == "https" }
			response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
				http.request(request)
			end
			return nil if response.code != '200'
			begin
				parsed = JSON.parse(response.body)
				return parsed['app_id']
			rescue
				return nil
			end
			return response
		end
		def self.get_ege_data(app_id, cookie_jar)
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
			# request["Content-Length"] = "57"
			request["Cookie"] = cookie_jar.plain
			request["X-Requested-With"] = "XMLHttpRequest"
			request.set_form_data(
				"ajaxAction" => "give_data",
				"ajaxModule" => "Ege",
				"ajax_app_id" => app_id,
			)
			req_options = { use_ssl: uri.scheme == "https" }
			response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
				http.request(request)
			end
			return nil if response.code != '200'
			begin
				parsed = JSON.parse(response.body)
				return parsed['data']['CoordinateStatusDataMessage']['Documents']['ServiceDocument']['CustomAttributes']['examResultList']['examResult']
			rescue
				return nil
			end
		end
	end

end