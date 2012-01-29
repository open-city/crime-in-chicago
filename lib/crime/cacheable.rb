require 'dalli'
require 'digest/md5'

module Cacheable
  def retain_in_memory(key)
    if settings.cacheable?
      @@dalli ||= Dalli::Client.new(settings.cacheable[:servers])

      poky_operation = @@dalli.get(key)
      unless poky_operation
        poky_operation = yield
        @@dalli.set(key, poky_operation)
      end
      poky_operation
    else
      yield
    end
  end
end
