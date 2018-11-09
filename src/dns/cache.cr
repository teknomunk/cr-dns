require "mergeheapqueue"

class DNS::Cache
	class CacheEntry
		enum Type
			Answer
			Authority
			Additional
		end
		getter question : DNS::RR
		getter answer : DNS::RR
		getter type : Type

		property expires : Time

		def self.index_string( type : DNS::RR::Type, cls : DNS::RR::Cls, name : String )
			"#{type} #{cls} #{name}"
		end
		def index_string()
			self.class.index_string( @question.type, @question.cls, @question.name )
		end

		def <( rhs )
			@expires < rhs.expires
		end
		
		def initialize( @question, @answer, @type, ttl )
			@expires = Time.now + Time::Span.new(0,0,ttl)
		end
	end

	@records : Hash(String,CacheEntry) = {} of String => CacheEntry
	@queue = MergeHeapQueue(CacheEntry).new

	def initialize()
		spawn do
			# Handle expiring entries from the cache
			loop {
				while !@queue.empty? && !(n=@queue.next).nil? && n.expires <= Time.now
					@queue.pop()
					@records.delete( n.index_string )
				end
				sleep 1
			}
		end
	end

	def insert( msg : DNS::Message )
		raise "TODO: determine how to handle caching messages with multiple questions" if msg.questions.size > 1

		q = msg.questions[0]
		msg.answers.each {|ans|
			cl = CacheEntry.new(q, ans, CacheEntry::Type::Answer, ans.ttl )
			@records[cl.index_string] = cl
			@queue.push( cl )
		}
	end
	def find( msg : DNS::Message ) : Bool
		is_match = false
		msg.questions.each {|q|
			idx = CacheEntry.index_string( q.type, q.cls, q.name )
			if !(entry=@records[ idx ]?).nil? && entry.expires >= Time.now
				is_match = true

				case entry.type
					when CacheEntry::Type::Answer
						msg.answers.push(entry.answer)
					when CacheEntry::Type::Authority
						msg.authority.push(entry.answer)
					when CacheEntry::Type::Additional
						msg.additional.push(entry.answer)
				end
			end
		}
		return is_match
	end
end
