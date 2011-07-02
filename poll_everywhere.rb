# @author Daniel Cohen
# @release_date July, 23 2010
# @website http://thenice.tumblr.com
# @email daniel.michael.cohen@gmail.com
# @license MIT license: http://www.opensource.org/licenses/mit-license.php

require 'net/http'

module PollEverywhere

	class Poll

		# Add any key of a poll to not have instantiated as a field in a Poll object
		DO_NOT_STORE_FIELD = %w(results options)
		CONFIG_FILE_URL = "#{RAILS_ROOT}/config/poll_everywhere.yml"

    def initialize
      self.create_ivar(:type) # create a field to store the type of poll
    end
    
		# Create cached access to the config file.
		#
		# @return [Array] Returns an array of a user's Polls
		def self.config
			@@config ||= YAML::load(File.open(CONFIG_FILE_URL))
		end

		# Pulls down the most recent polls from the server, and store in class
		# variable @@polls and return the array.
		#
		# @return [Array] Returns an array of a user's Polls
		def self.refresh
			self.request
		end

		# Selects all multiple choice polls from a user's account
		# and utilizes the cached @@poll variable.
		#
		# @return [Array] Returns an array of a user's multiple choice Polls
		def self.multiple_choice
			self.all.select { |poll| poll.type == "MultipleChoicePoll" }
		end

		# Selects all free text polls from a user's account
		# and utilizes the cached @@poll variable.
		#
		# @return [Array] an array of a user's free text polls
		def self.free_text
			self.all.select { |poll| poll.type == "FreeTextPoll" }
		end

		# Searches through the cached @@poll array for a given poll
		# identified by the permalink
		#
		# @param permalink referred to as poll_id
		# @return [Array] an array of matching a user's free text polls
		def self.find(poll_id)
			self.all.select { |poll| poll.permalink.include?(poll_id) }
		end

		# Returns the entire cached @@poll array
		# or makes an initial request if one hasn't yet been made
		#
		# @return [Array] all of the user's polls
		def self.all
			@@poll_objects rescue self.request
		end

		# Searches through the cached @@poll array for a given poll
		# identified by the title field
		# 
		# @param title the title of a poll
		# @return [Array] all of the user's polls
		def self.find_by_title(title)
			self.all.select { |poll| poll.title.include?(title) }
		end

		# Fetches detail json from server for specific multiple choice
		# poll. This method is depricated since the addition of the
		# detailed.json feed.
		# @depricated
		# 
		# @param the permalink for the poll referred to as poll_id
		# @return [Hash] of the values for a given poll
		def self.request_multiple_choice(poll_id)
			poll_json = `curl #{config['urls']['detailed_multiple_choice']}/#{poll_id}.json`
			self.from_hash(JSON.parse(poll_json))
		end

		# Pass in a keyword string, and this method will count the vote.
		# It will count repeat votes by default. Returns Nil no matter what
		# Does not provide feedback
		# @todo make this method return true for success and false for error
		#
		# @param keyword for a poll to vote (an sms keyword)
		# @return nil this should be fixed
		def self.vote(keyword)
			Net::HTTP.get_print(URI.parse("#{config['urls']['vote']}?response=#{keyword.gsub(' ', '+')}"))
		end

		# @instance_methods

		# @constructors

		# Instantiates a new Poll object from a hash of values.
		# 
		# @param [Hash] A hash of poll values
		# @return [PollEverywhere::Poll] a new instanc of a Poll containing the Hash keys and values
		def self.from_hash(hash)
			new_poll = self.new
			hash.each_pair do |key, value|
				unless DO_NOT_STORE_FIELD.include?(key)
					new_poll.create_ivar(key)
					new_poll.send("#{key.to_s}=", value)
				end
			end
		
			return new_poll
		end

		# Given a poll, this method creates a new field, set's the value of field_nam_json 
		# provides the appropriate accessors and mutators to store and access the json value
		#
		# @param new_poll the poll to operate on
		# @param field_name the name of the field to add
		# @value the value to set the new_field to in JSON format

		# @return nil
		def self.create_and_set_json_field_for(new_poll, field_name, value)
			new_poll.create_ivar("#{field_name}_json")
			new_poll.send("#{field_name}_json=", value)
			new_poll.class.class_eval do
				eval("def #{field_name}; JSON.parse(self.send('#{field_name}_json')) rescue []; end")
			end
		end

		# Get the number of results for a keyword in a Poll
		#
		# returns 0 if that keyword is not found in this Poll. Keywords are NOT
		# case sensitive
		#
		# @param keyword for the poll to lookup
		# @return an integer representing the number of responses, or 0 if the keyword didn't exist
		def result_count_for(keyword)
			options.select { |h| h["keyword"].downcase == keyword.downcase }[0]["results_count"] rescue 0
		end

		# Get the percentage of results for a keyword in a Poll
		#
		# returns 0 if that keyword is not found in this Poll. Keywords are NOT
		# case sensitive
		#
		# @param keyword for the poll to lookup
		# @return a float representing the percentage of responses, or 0 if the keyword didn't exist
		def result_percentage_for(keyword)
			options.select { |h| h["keyword"].downcase == keyword.downcase }[0]["results_percentage"].to_f rescue 0.0
		end

		# A utility method that should be private but requires public access.
		# This method does what it says... it creats an ivar for a given symbol
		#
		#
		# @param symbol ivar name
		def create_ivar(symbol)
	    self.class.module_eval( "def #{symbol}() @#{symbol}; end" )
	    self.class.module_eval( "def #{symbol}=(val) @#{symbol} = val; end")
		end

		private 

		# Makes the request to PollEverywhere to get the current detailed
		# Poll data. Sets two class viariabls, @polls and @poll_objects
		#
		#
		def self.request
			polls_json = `curl http://#{config['username']}:#{config['password']}@#{config['urls']['detailed_poll_list']}`
			@@polls = JSON.parse(polls_json)
			@@poll_objects = @@polls.collect { |poll_hash| self.from_hash(poll_hash.values.first) }
		end

	end

end