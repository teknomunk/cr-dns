require "./spec_helper"

describe DNS do
	describe DNS::Server do
		describe "#run" do
			server = DNS::Server.new()
			server.add_listener( DNS::Server::UDPListener.new( "localhost", 15000 ) )
			server.add_listener( DNS::Server::TCPListener.new( "localhost", 15000 ) )
			server.query("example.com.", DNS::RR::Type::A) {|req,q|
				rr = DNS::RR::A.new()
				rr.name = req.message.questions[0].name
				rr.ip_address = "127.0.0.1"
				rr.ttl = 5
				req.message.answers.push(rr)
				true
			}
			spawn do
				server.run
			end

			sleep 0.5

			it "can resolve A records" do
				resolv = DNS::Resolver::Remote.new( server.channel_listener )
				res = resolv.resolve( DNS::Message.simple_query( "A", "example.com" ) )
				res.response_code.should eq(DNS::Message::ResponseCode::NoError)
				res.truncated.should eq(false)
				res.answers.size.should eq(1)
				if (rr=res.answers[0]).is_a?(DNS::RR::A)
					rr.name.should eq("example.com.")
					rr.ip_address.should eq("127.0.0.1")
				end
			end

			it "can resolve over UDP" do
				resolv = DNS::Resolver::Remote.new( DNS::Resolver::UDPChannel.new("localhost",15000) )
				res = resolv.resolve( DNS::Message.simple_query( "A", "example.com" ) )
				res.response_code.should eq(DNS::Message::ResponseCode::NoError)
				res.truncated.should eq(false)
				res.answers.size.should eq(1)
				if (rr=res.answers[0]).is_a?(DNS::RR::A)
					rr.name.should eq("example.com.")
					rr.ip_address.should eq("127.0.0.1")
				end
			end

			it "can resolve over TCP" do
				resolv = DNS::Resolver::Remote.new( DNS::Resolver::TCPChannel.new("localhost",15000) )
				res = resolv.resolve( DNS::Message.simple_query( "A", "example.com" ) )
				res.response_code.should eq(DNS::Message::ResponseCode::NoError)
				res.truncated.should eq(false)
				res.answers.size.should eq(1)
				if (rr=res.answers[0]).is_a?(DNS::RR::A)
					rr.name.should eq("example.com.")
					rr.ip_address.should eq("127.0.0.1")
				end
			end

			it "can return results from a cache" do
				resolv = DNS::Resolver::Remote.new( DNS::Resolver::TCPChannel.new("localhost",15000) )
				resolv.cache = (cache=DNS::Cache.new())
				
				# Populate the cache
				resolv.resolve( DNS::Message.simple_query( "A", "example.com" ) )
				cache.entry_count.should eq(1)

				# Make sure the response is correct
				res = resolv.resolve( DNS::Message.simple_query( "A", "example.com" ), cache_only: true )
				res.response_code.should eq(DNS::Message::ResponseCode::NoError)
				res.truncated.should eq(false)
				res.answers.size.should eq(1)
				if (rr=res.answers[0]).is_a?(DNS::RR::A)
					rr.name.should eq("example.com.")
					rr.ip_address.should eq("127.0.0.1")
				end
			end
		end # describe "#run" do
	end # describe DNS::Server do
end # describe DNS do
