abstract class DNS::RR
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
	TYPES = %w(SOA A AAAA NS MX OPT)

	module CommonRegex
		DNAME="(@|[A-Za-z\-0-9\.]+)"
		ZONE_DNAME="(@|(?:\\*\\.)?[A-Za-z\-0-9\.]+)"
		WS="[ \t]+"
		TIME="([0-9]+[WDMwdm])?"
		CLS="(IN|)"
		IPV4_ADDR="([0-9\.]+)"
		IPV6_ADDR="([0-9A-Fa-f\.:]+)"
		ZONE_OPTIONAL="(?:#{ZONE_DNAME}?#{WS})(?:#{TIME}#{WS})?#{CLS}?#{WS}"
	end

	enum Cls
		IN = 1
	end
	IN = Cls::IN

	property name : String = "."
	property type : Type = Type::ANY
	property cls : Cls = Cls::IN
	property ttl : UInt32 = 0

	abstract def set_raw_data( packet : Bytes, rdata : Bytes )
	abstract def get_raw_data( packet : Bytes ) : Bytes

	def self.decode_query( io : IO, packet : Bytes ) : DNS::RR
		name = DNS.decode_name(io,packet)
		type = Type.new(io.read_network_short.to_i32)
		cls= Cls.new(io.read_network_short.to_i32)

		# Create class based on resource record type
		rr : DNS::RR
		{% begin %}
		case type
			{% for type in TYPES %}
				when Type::{{type.id}}
					rr = DNS::RR::{{type.id}}.new()
			{% end %}
			else
				raise "Unsupported type #{cls}:#{type}"
		end
		{% end %}

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
			data = Bytes.new(data_length)
			io.read data
			raise "Expecting #{data_length} bytes" if data.nil?

			rr.set_raw_data( packet, data )
		end
		rr.finish_decode()
		return rr
	end
	def finish_decode()
	end
	def encode_query( io : IO )
		DNS.encode_name(@name, io, io.to_slice)
		io.write_network_short( @type.to_i32 )
		io.write_network_short( @cls.to_i32 )
	end
	def encode( io : IO )
		rd = get_raw_data(io.to_slice)
		raise "Error encoding data" if rd.nil?

		encode_query(io)
		io.write_network_long( @ttl )
		io.write_network_short( rd.size )
		io.write rd.to_slice
	end
	def inspect( io : IO )
		io << "#<DNS::RR::"
		io << @cls
		io << "::"
		io << @type
		io << " "
		@name.inspect(io)
		io << " = "
		raw_data.inspect(io)
		io << ">"
	end
end

require "./rr/*"
