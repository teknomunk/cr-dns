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
			res = resolv.resolve( DNS::Message.simple_query( "A", "example.com" ) )
			res.response_code.should eq(DNS::Message::ResponseCode::NoError)
			res.truncated.should eq(false)
			res.answers.size.should eq(1)
			puts res.inspect
		end
	end
end
