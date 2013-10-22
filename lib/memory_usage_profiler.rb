require_relative 'memory_usage_profiler/version'

require 'objspace'

module MemoryUsageProfiler

  MEMORY_PROFILE_GC_STAT_HASH = {}
  MEMORY_PROFILE_BANNER = ['name']
  MEMORY_PROFILE_PROCS  = []
  MEMORY_PROFILE_DURATION = (ENV['RUBY_MEMORY_PROFILE_DURATION'] || 1).to_i
  MEMORY_PROFILE_OUTPUT_PATH = ENV['RUBY_MEMORY_PROFILE'] || 'memory-profile-result'

  def self.add(*name, &b)
    MEMORY_PROFILE_BANNER.concat name
    MEMORY_PROFILE_PROCS << b
  end

  if GC.respond_to?(:malloc_allocated_size)
    add 'malloc_allocated_size', 'malloc_allocations' do |result|
      result.concat [GC.malloc_allocated_size, GC.malloc_allocations]
    end
  end

  add 'memsize_of_all' do |result|
    result << ObjectSpace.memsize_of_all
  end

  add(*GC.stat.keys) do |result|
    GC.stat(MEMORY_PROFILE_GC_STAT_HASH)
    result.concat MEMORY_PROFILE_GC_STAT_HASH.values
  end

  def self.add_proc_meminfo(file, fields)
    return unless FileTest.exist?(file)
    regexp = /(#{fields.join("|")}):\s*(\d+) kB/
    # check = {}; fields.each{|e| check[e] = true}
    add(*fields) do |result|
      text = File.read(file)
      text.scan(regexp){
        # check.delete $1
        result << $2
        ''
      }
      # raise check.inspect unless check.empty?
    end
  end

  add_proc_meminfo '/proc/meminfo', %w(MemTotal MemFree)
  add_proc_meminfo '/proc/self/status', %w(VmPeak VmSize VmHWM VmRSS)

  if FileTest.exist?('/proc/self/statm')
    add(*%w(size resident share text lib data dt)) do |result|
      result.concat File.read('/proc/self/statm').split(/\s+/)
    end
  end

  h = {}
  T_TYPES = %i{
    T_NONE T_OBJECT T_CLASS T_MODULE T_FLOAT T_STRING T_REGEXP T_ARRAY T_HASH T_STRUCT
    T_BIGNUM T_FILE T_DATA T_MATCH T_COMPLEX T_RATIONAL T_NIL T_TRUE T_FALSE T_SYMBOL
    T_FIXNUM T_UNDEF T_NODE T_ICLASS T_ZOMBIE
  }
  add T_TYPES.map{|e| "count_of_#{e.to_s}"} do |result|
    ObjectSpace.count_objects(h)
    T_TYPES.each{|t|
      result << (h[t] || 0)
    }
  end

  add T_TYPES.map{|e| "size_of_#{e.to_s}"} do |result|
    ObjectSpace.count_objects_size(h)
    T_TYPES.each{|t|
      result << (h[t] || 0)
    }
  end

  def self.banner_items
    MEMORY_PROFILE_BANNER
  end

  def self.banner
    banner_items.join("\t")
  end

  def self.kick(name, &callback)
    result = [name.to_s]
    MEMORY_PROFILE_PROCS.each{|pr|
      pr.call(result)
    }
    callback.call(result)
  end

  def self.start_thread(duration=MEMORY_PROFILE_DURATION, file=MEMORY_PROFILE_OUTPUT_PATH)
    require 'time'

    file = if file == '-'
             STDOUT
           else
             open(file, 'w')
           end
    file.sync = true

    file.puts banner

    @@thread_running = true

    Thread.new do
      Thread.current.abort_on_exception = true
      while @@thread_running
        kick(Time.now.iso8601) { |result|
          file.puts result.join("\t")
          sleep duration
        }
      end
    end
  end

  def self.stop_thread
    @@thread_running = false
  end
end

if $0 == __FILE__
  MemoryUsageProfiler.start_thread(1, '-')
  100_000_000.times{''}
end
