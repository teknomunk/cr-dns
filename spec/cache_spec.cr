require "./spec_helper"

describe DNS do
	describe DNS::Cache do
		it "caches data, then expires it after a time" do
			cache = DNS::Cache.new()

			msg1 = DNS::Message.simple_query( "A", "localhost." )
			msg1.answers.push( rr=DNS::RR::A.new() )
			rr.ip_address = "127.0.0.1"
			rr.name = "localhost."
			rr.ttl = 2

			cache.insert( msg1 )
			cache.entry_count.should eq(1)

			res = cache.find( msg2=DNS::Message.simple_query( "A", "localhost." ) )
			res.should be_true
			msg2.answers.size.should eq(1)
			rr = msg2.answers[0]
			rr.should be_a(DNS::RR::A)
			if rr.is_a?(DNS::RR::A)
				rr.ip_address.should eq("127.0.0.1")
				rr.name.should eq("localhost.")
				rr.ttl.should eq(2)
			end

			sleep 5

			res = cache.find( msg2=DNS::Message.simple_query( "A", "localhost." ) )
			res.should be_false
			cache.entry_count.should eq(0)
		end
	end
end
