class DNS::Zone
	def initialize( path : String )
		File.open(path,"r") {|f| do_initialize(f) }
	end
	def initialize( io : IO )
		do_initialize(io)
	end

	@origin = "."
	@ttl = 0
	property records : Array(RR) = [] of RR

	macro update_optional(list)
		{% for item in list %}
			{{item.id}} = new_{{item.id}} if new_{{item.id}} != ""
		{% end %}
	end

	DNAME="(@|[a-z\-0-9\.]+)"
	WS="[ \t]+"
	TTL="([0-9]+[WDMwdm])?"
	CLS="(IN|)"
	IPV4_ADDR="([0-9\.]+)"
	IPV6_ADDR="([0-9A-Fa-f\.:]+)"

	private def do_initialize( io : IO)
		ttl = 0
		cls = ""
		name = ""
		while !(line=io.gets('\n')).nil?
			line = line.gsub(/[ \t]*;.*$/,"")
			case line
				when /^\$ORIGIN #{DNAME}$/
					@origin = $1
				when /^#{DNAME}?#{WS}#{TTL}#{WS}#{CLS}#{WS}SOA#{WS}#{DNAME}#{WS}(.*)$/
					new_name,new_ttl,new_cls = $1,$2,$3
					dname = $4
					rdata = $5

					update_optional [name, ttl, cls]

					rr = DNS::RR.new()
					rr.type = DNS::RR::Type::SOA
					rr.name = ( name == "@" ? @origin : name )
					rr.raw_data = rdata.to_slice

					@records.push(rr)
				when /^#{DNAME}?#{WS}#{TTL}#{WS}#{CLS}#{WS}A#{WS}#{IPV4_ADDR}$/
					new_name,new_ttl,new_cls = $1,$2,$3
					addr = $4

					update_optional [name, ttl, cls]

					rr = DNS::RR.new()
					rr.type = DNS::RR::Type::A
					rr.name = ( name == "@" ? @origin : name )
					rr.data = addr

					@records.push(rr)
				when /^#{DNAME}?#{WS}#{TTL}#{WS}#{CLS}#{WS}AAAA#{WS}#{IPV6_ADDR}$/
					new_name,new_ttl,new_cls = $1,$2,$3
					addr = $4

					update_optional [name, ttl, cls]

					rr = DNS::RR.new()
					rr.type = DNS::RR::Type::AAAA
					rr.name = ( name == "@" ? @origin : name )
					rr.data = addr

					@records.push(rr)
				when /^#{DNAME}?#{WS}#{TTL}#{WS}#{CLS}#{WS}NS#{WS}#{DNAME}$/
					new_name,new_ttl,new_cls = $1,$2,$3
					nameserver = $4

					update_optional [name, ttl, cls]

					rr = DNS::RR.new()
					rr.type = DNS::RR::Type::NS
					rr.name = ( name == "@" ? @origin : name )
					rr.data = nameserver

					@records.push(rr)
				else
					puts "Unhandled line #{line}"
			end
		end
	end
end
