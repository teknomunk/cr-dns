require "./spec_helper"

describe DNS do
  # TODO: Write tests
	describe DNS::Message do
		describe "#decode" do
			it "Decodes DNS message" do
				msg = DNS::Message.decode(
					 ("295785900001"+
					  "0001000000010c6d656469612d736572"+
					  "76657207706f6c61726973036c616e00"+
					  "00010001c00c000100010000000a0004"+
					  "c0a814090000291000000080000000").to_slice_from_hexstring
				)
				msg.query.should eq(DNS::Message::Response)
				msg.query_type.should eq(DNS::Message::QueryType::Query)
				msg.authoritative.should eq(true)
				msg.truncated.should eq(false)
				msg.recursion_desired.should eq(true)
				msg.recursion_available.should eq(true)
				msg.response_code.should eq(DNS::Message::NoError)
				msg.authenticated.should eq(false)

				msg.questions[0].type.should eq(DNS::RR::Type::A)
				msg.questions[0].name.should eq("media-server.polaris.lan.")

				rr = msg.answers[0]

				rr.type.should eq(DNS::RR::Type::A)
				rr.name.should eq("media-server.polaris.lan.")
				if rr.is_a?(DNS::RR::A)
					rr.ip_address.should eq("192.168.20.9")
				end
				rr.ttl.should eq(10)

				msg.additional[0].type.should eq(DNS::RR::Type::OPT)
				if (opt=msg.additional[0]).is_a?(DNS::RR::OPT)
					opt.udp_payload_size.should eq(4096)
					opt.accept_dnssec.should eq(true)
					opt.options.size.should eq(0)
				end
			end
		end
		describe "#encode" do
			it "Encodes DNS message" do
				msg = DNS::Message.new
				msg.id = 10583_u16
				msg.query = DNS::Message::Response
				msg.query_type = DNS::Message::QueryType::Query
				msg.authoritative = true
				msg.recursion_desired = true
				msg.recursion_available = true
				msg.response_code = DNS::Message::NoError
				msg.authenticated = false

				rr = DNS::RR::A.new
				rr.name = "media-server.polaris.lan."
				msg.questions.push(rr)

				rr = DNS::RR::A.new
				rr.name = "media-server.polaris.lan."
				rr.ip_address = "192.168.20.9"
				rr.ttl = 10
				msg.answers.push(rr)

				rr = DNS::RR::OPT.new
				rr.udp_payload_size = 4096
				rr.accept_dnssec = true
				msg.additional.push(rr)

				#puts msg.inspect
				msg.encode().should eq(
					 ("295785900001"+
					  "0001000000010c6d656469612d736572"+
					  "76657207706f6c61726973036c616e00"+
					  "00010001c00c000100010000000a0004"+
					  "c0a814090000291000000080000000").to_slice_from_hexstring
				)
			end
		end
	end
end
