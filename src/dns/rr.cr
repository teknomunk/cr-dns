class DNS::RR
	enum Type
		# Pseudo record types
		ANY			= 255
		AXFR			= 252
		IXFR			= 251
		OPT			= 41

		# Active record types
		A			= 1
		AAAA			= 28
		AFSDB		= 18
		APL			= 42
		CAA			= 257
		CDNSKEY		= 60
		CDS			= 59
		CERT			= 37
		CNAME		= 5
		DHCID		= 49
		DLV			= 32769
		DNAME		= 39
		DNSKEY		= 48
		DS			= 43
		HIP			= 55
		IPSECKEY		= 25
		KX			= 36
		LOC			= 29
		MX			= 15
		NAPTR		= 35
		NS			= 2
		NSEC			= 47
		NSEC3		= 50
		NSEC3PARAM	= 51
		OPENPGPKEY	= 61
		PTR			= 12
		RRSIG		= 46
		RP			= 17
		SIG			= 24
		SOA			= 6
		SRV			= 33
		SSHFP		= 44
		TA			= 32768
		TKEY			= 249
		TLSA			= 52
		TSIG			= 250
		TXT			= 16
		URI			= 256

		# Obsolete record types
		MD			= 3
		MF			= 4
		MAILA		= 254
		MB			= 7
		MG			= 8
		MR			= 9
		MINFO		= 14
		MAILB		= 253
		WKS			= 11
		NB			= 32
		NBSTAT		= 33
		NULL			= 10
		A6			= 38
		NXT			= 30
		KEY			= 25
		HINFO		= 13
		X25			= 19
		ISDN			= 20
		RT			= 21
		NSAP			= 22
		NSAP_PTR		= 23
		PX			= 26
		EID			= 31
		NIMLOC		= 32
		ATMA			= 34
		SINK			= 40
		GPOS			= 27
		UINFO		= 100
		UID			= 101
		GID			= 102
		UNSPEC		= 103
		SPF			= 99
	end
	A = Type::A
	AAAA = Type::AAAA

	enum Cls
		IN = 1
	end
	IN = Cls::IN
	property name : String = "."
	property type : Type = Type::ANY
	property cls : Cls = Cls::IN
	property ttl : UInt32 = 0
	property raw_data : String = ""

	def self.decode_query( io : IO, packet : Bytes ) : DNS::RR
		name = decode_name(io,packet)
		type = Type.new(io.read_network_short.to_i32)
		cls= Cls.new(io.read_network_short.to_i32)

		if type == Type::OPT
			rr = DNS::RR::OPT.new()
		else
			rr = DNS::RR.new()
		end
		rr.cls = cls
		rr.name = name
		rr.type = type
		
		return rr
	end
	def self.decode( io : IO, packet : Bytes ) : DNS::RR
		rr = decode_query(io,packet)

		rr.ttl = io.read_network_long

		data_length = io.read_network_short
		if data_length != 0
			data = io.gets(data_length)
			raise "Expecting #{data_length} bytes" if data.nil?

			rr.raw_data = data
		end
		if rr.is_a?(DNS::RR::OPT)
			rr.decode_options()
		end
		return rr
	end
	def encode_query( io : IO )
		DNS::RR.encode_name(@name, io, io.to_slice)
		io.write_network_short( @type.to_i32 )
		io.write_network_short( @cls.to_i32 )
	end
	def encode( io : IO )
		encode_query(io)
		io.write_network_long( @ttl )
		io.write_network_short( @raw_data.size )
		io.write @raw_data.to_slice
	end
	def data() : String
		case type
			when Type::A
				@raw_data.bytes.map {|s| "%d" % s }.join(".")
			else
				@raw_data
		end
	end
	def data=( s : String )
		case type
			when Type::A
				io = IO::Memory.new()
				s.split(".")[0,4].each {|i|
					io.write_byte i.to_u8
				}
				@raw_data = String.new( io.to_slice )
			else
				@raw_data = s
		end
	end
	def inspect( io : IO )
		io << "#<DNS::RR::"
		io << @cls
		io << "::"
		io << @type
		io << " "
		@name.inspect(io)
		io << " = "
		data.inspect(io)
		io << ">"
	end
end
