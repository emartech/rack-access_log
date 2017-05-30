# Rack::AccessLog

This is a middleware for ruby / rack based webservice access logging. The implementation doesn't

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-access_log'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-access_log

## Usage

#### First we need a logger that can accept and handle hash messages.

You can use the ruby build in with "custom" formatter.

```ruby
require 'json'
require 'logger'

json_logger = Logger.new(STDOUT)
json_logger.formatter = proc do |severity, datetime, progname, msg|
  JSON.dump(msg) + "\n"
end
```

Or you can use logger implementations such as [TwP/logging](https://github.com/TwP/logging) gem

```ruby
require 'logging'

json_logger = Logging.logger["AccessLog"]
appender = Logging.appenders.stdout(:layout => Logging.layouts.json)
json_logger.add_appenders(appender)
```

#### Than use it in our middleware stack
##### config.ru

```ruby
require 'rack/access_log'
use Rack::AccessLog, json_logger

require 'rack/response'
run proc{|env| Rack::Response.new.finish }
```

That's all Folks!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-access_log. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

