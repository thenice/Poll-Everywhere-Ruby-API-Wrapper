** PollEverywhere API Wrapper for Ruby **
* Daniel Cohen
* July, 23 2010
* http://thenice.tumblr.com
* daniel.michael.cohen@gmail.com
* Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

** UPDATE: JULY, 1ST 2011 **
Removed call to deprecated web service, detailed.json. Fixed so that the wrapper works with updated API.

== What is PollEverywhere?
Poll Everywhere is a premium real-time web-based polling service. Poll Everywhere is unique in that it allows users to submit poll responses via SMS, web, twitter, and blog widget-- and will display the results on a chart updated in real time. If you are looking for a full-featured polling service, check out Poll Everywhere. 

== Synopsis
This is a Ruby library that wraps the Poll Everywhere Restful API. Each Poll is represented by a Ruby object of type PollEverywhere::Poll and includes some convenient methods for interfacing with your Poll Everywhere account. Requires a PollEverywhere Account. Visit Polleverywhere.com for more information. Stay tuned for more features coming soon!

== Installation
1. Open the poll_everywhere.rb file, and make sure that the CONFIG_FILE_URL points to your config file. By default. the config file is called: "#{RAILS_ROOT}/config/poll_everywhere.yml"
2. Make sure the poll_everywhere.rb file is loaded into your application. If your application is a Rails app, just put it in your /lib directory
3. Edit the poll_everywhere.yml file to contain your PollEverywhere account credentials

== Sample Usage

PollEverywhere::Poll.all -- Requests all polls in the user's account. Subsequent calls to Poll.all() look in a cached copy. Use Poll.refresh() to reload the cache. Returns an array of Poll objects.

PollEverywhere::Poll.find_by_title("title") -- Returns an array of matching Polls from the user's account

PollEverywhere::Poll.find("LTE4MzMzNTgxNzI") -- Find a Poll by the permalink value

PollEverywhere::Poll.vote("keyword") -- Records a response for a given Poll.