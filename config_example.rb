# 
# COPYRIGHT LESTER COVEY,
#
# 2022

# Edit your config data here
CACHE_FILE_LOCATION = "#{__dir__}/bruh_cache.bin"
COOKIE_FILE_LOCATION = "#{__dir__}/bruh_cookies.bin"
SHELL_COMMAND = "sudo report \"BRUH: "
REG_CODE = "1111-2222-3333-4444"
ID_NUM = "123123"
MOSRU_LOGIN = "***"
MOSRU_PASSWORD = "***"

# Service area
class Config
	@@cache_file_location = CACHE_FILE_LOCATION
	@@cookie_file_location = COOKIE_FILE_LOCATION
	@@shell_command = SHELL_COMMAND
	@@reg_code = REG_CODE
	@@id_num = ID_NUM
	@@mosru_login = MOSRU_LOGIN
	@@mosru_password = MOSRU_PASSWORD
	
	def self.cache_file_location
		@@cache_file_location
	end
	def self.cookie_file_location
		@@cookie_file_location
	end
	def self.shell_command
		@@shell_command
	end
	def self.reg_code
		@@reg_code
	end
	def self.id_num
		@@id_num
	end
	def self.mosru_login
		@@mosru_login
	end
	def self.mosru_password
		@@mosru_password
	end
end