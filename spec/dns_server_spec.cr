require "./spec_helper"

describe DNS do
	describe DNS::Server do
		describe "#run" do
			spawn do
				server = DNS::Server.new( udp_port: 8000, tcp_port: 8000)
				server.run
			end
			sleep 1
			puts `dig @localhost -p8000 example.com`
		end
	end
end
