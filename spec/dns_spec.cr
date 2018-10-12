require "./spec_helper"

describe DNS do
  # TODO: Write tests
	describe DNS::Message do
		describe "#decode" do
			msg = DNS::Message.decode(
			      ("295785900001"+
			       "0001000000010c6d656469612d736572"+
			       "76657207706f6c61726973036c616e00"+
			       "00010001c00c000100010000000a0004"+
			       "c0a814090000291000000080000000").to_slice_from_hexstring
			)
			puts msg.inspect
		end
	end

  #it "works" do
  #  false.should eq(true)
  #end
end
