require "./spec_helper"

describe DNS do
	describe DNS::Server do
		describe "#run" do
			server = DNS::Server.new() # udp_port: 8000, tcp_port: 8000)
			server.query("example.com.", DNS::RR::Type::A) {|req,q|
				rr = DNS::RR::A.new()
				rr.name = req.message.questions[0].name
				rr.ip_address = "127.0.0.1"
				req.message.answers.push(rr)
				true
			}
			spawn do
				server.run
			end

			resolv = DNS::Resolver.new( server.channel_listener )
#			sleep 1
#			puts `dig @localhost -p8000 example.com`
		end
	end
end
