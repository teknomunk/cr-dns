class IO
	def read_network_short()
		b0 = read_byte
		b1 = read_byte
		raise "Expecting two bytes" if b0.nil? || b1.nil?

		b0.to_u16 << 8 | b1
	end
end

class DNS::Message
	enum Type
		Query
		Response
	end
	enum QueryType
		Query
		InverseQuery
		Status
		Notify
		Update
	end
	enum ResponseCode
		NoError
		FormatError
		ServerFailure
		NameError
		NotImplemented
		Refused
		YX_Domain
		YX_RR_Set
		NX_RR_Set
		NotAuth
		NotZone
	end

	property id : UInt16 = 0

	property query : Type = Type::Query
	property query_type : QueryType = QueryType::Query
	property authoritative : Bool = false
	property truncated : Bool = false
	property recursion_desired : Bool = false
	property recursion_available : Bool = false
	property response_code : ResponseCode = ResponseCode::NoError
	property authenticated : Bool = false
	property accept_non_auth : Bool = true

	property questions  : Array(DNS::RR) = [] of DNS::RR
	property answers	: Array(DNS::RR) = [] of DNS::RR
	property authority	: Array(DNS::RR) = [] of DNS::RR
	property additional : Array(DNS::RR) = [] of DNS::RR

	def self.decode( packet : Bytes )
		decode( IO::Memory.new(packet), packet )
	end

	def self.decode( io : IO, packet : Bytes )
		msg = DNS::Message.new
		msg.id = io.read_network_short
		flags = io.read_network_short
		msg.query = flags & 0x8000 == 0x8000 ? Type::Response : Type::Query
		case (flags >> 11) & 0x0F
			when 0
				msg.query_type = QueryType::Query
			when 1
				msg.query_type = QueryType::InverseQuery
			when 2
				msg.query_type = QueryType::Status
			when 4
				msg.query_type = QueryType::Notify
			when 5
				msg.query_type = QueryType::Update
		end

		msg.authoritative = !!(flags & 0x0400 == 0x0400)
		msg.truncated = !!(flags & 0x0200 == 0x0200)
		msg.recursion_desired = !!(flags & 0x0100 == 0x0100)
		msg.recursion_available = !!(flags & 0x0080 == 0x0080)
		msg.authenticated = !!(flags & 0x0020 == 0x0020)
		msg.accept_non_auth = !!(flags & 0x0010 == 0x0010)
		case flags&0x0F
			when 0
				msg.response_code = ResponseCode::NoError
			when 1
				msg.response_code = ResponseCode::FormatError
			when 2
				msg.response_code = ResponseCode::ServerFailure
			when 3
				msg.response_code = ResponseCode::NameError
			when 4
				msg.response_code = ResponseCode::NotImplemented
			when 5
				msg.response_code = ResponseCode::Refused
			when 6
				msg.response_code = ResponseCode::YX_Domain
			when 7
				msg.response_code = ResponseCode::YX_RR_Set
			when 8
				msg.response_code = ResponseCode::NX_RR_Set
			when 9
				msg.response_code = ResponseCode::NotAuth
			when 10
				msg.response_code = ResponseCode::NotZone
			else
				msg.response_code = ResponseCode::ServerFailure
		end

		#p = packet + 12

		question_count = io.read_network_short #packet[4].to_u16 << 8 | packet[5]
		answer_record_count = io.read_network_short #packet[6].to_u16 << 8 | packet[7]
		authority_count = io.read_network_short #packet[8].to_u16 << 8 | packet[9]
		additional_record_count = io.read_network_short #packet[10].to_u16 << 8 | packet[11]

		question_count.times {
			rr = DNS::RR.decode_query(io,packet)
			msg.questions.push(rr) if !rr.nil?
		}

		answer_record_count.times {
			rr = DNS::RR.decode(io,packet)
			msg.answers.push(rr) if !rr.nil?
		}

		authority_count.times {
			rr = DNS::RR.decode(io,packet)
			msg.answers.push(rr) if !rr.nil?
		}

		additional_record_count.times {
			rr = DNS::RR.decode(io,packet)
			msg.additional.push(rr) if !rr.nil?
		}

		return msg
	end
end
