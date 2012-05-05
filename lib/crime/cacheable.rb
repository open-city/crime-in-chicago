require 'dalli'
require 'digest/md5'

module Cacheable
  def retain_in_cache(key)
    if true# settings.cacheable?
      sha_key = sha(key.to_s)
#      @@dalli ||= Dalli::Client.new(settings.cacheable[:servers])
      if development?
        @@dalli ||= Dalli::Client.new("localhost:11211")
      elsif production?
        @@dalli ||= Dalli::Client.new("#{ENV["MEMCACHE_SERVERS"]}:11211", {
          :username => "#{ENV["MEMCACHE_USERNAME"]}",
          :password => "#{ENV["MEMCACHE_PASSWORD"]}"
        })
      end

      poky_operation = @@dalli.get(sha_key)
      unless poky_operation
        poky_operation = yield
        @@dalli.set(sha_key, poky_operation)
      end
      poky_operation
    else
      yield
    end
  end

  def sha(key)
    Digest::SHA1.hexdigest(key)
  end
end
