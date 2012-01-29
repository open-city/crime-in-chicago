class Configuration
  def load!(yaml = nil)
    @@configuration ||= YAML.load_file("./config/#{yaml}"); self
  end

  def method_missing(sym, *args, &block)
    @@configuration[sym] || super(sym, args, block)
  end
end
