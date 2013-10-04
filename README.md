# Ruby's MemoryUsageProfiler

Collect memory usage profiling informations from CRuby runtime and Linux pseudo filesystems.

Originally written by @_ko1 on URL below.
 * http://www.atdot.net/sp/view/fd73um

## Installation

Add this line to your application's Gemfile:

    gem 'ruby-memory-usage-profiler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-memory-usage-profiler

## Usage

To run profiler itself (without any other ruby code):

    $ run_ruby_memory_usage_profiler

This program writes profiler result in 'memory-profile-result' of current directory, in each 1 second.

    $ run_ruby_memory_usage_profiler [DURATION sec] [OUTPUT PATH]

For stdout, specify '-'

    $ run_ruby_memory_usage_profiler 5 -

### From your own code

Kick `MemoryUsageProfiler#kick` with block how to process results each time you want.

    each_time_you_want do
      MemoryUsageProfiler.kick('my_program_label') do |result|
        send_to_anywhere_by_myself(result)
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

* @_ko1
* @tagomoris

## License

* This is licensed by the license ruby itself
