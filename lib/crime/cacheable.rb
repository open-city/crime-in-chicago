require 'dalli'
require 'digest/md5'

module Cacheable
  def dalli_settings
    if production?
      ["#{ENV["MEMCACHIER_SERVERS"]}", {
        :username => "#{ENV["MEMCACHIER_USERNAME"]}",
        :password => "#{ENV["MEMCACHIER_PASSWORD"]}"
      }]
    elsif development?
      ["localhost:11211"]
    end
  end

  def retain_in_cache(key)
    if true# settings.cacheable?
      sha_key = sha(key.to_s)

      poky_operation = settings.cache.get(sha_key)
      unless poky_operation
        poky_operation = yield
        settings.cache.set(sha_key, poky_operation)
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
