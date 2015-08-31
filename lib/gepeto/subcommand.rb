module Gepeto
  module Subcommand
    def self.names
      @@register ||= {}
      @@register.keys
    end

    def self.register(implementor, name, option_builder = nil)
      @@register ||= {}
      @@register[name]||= {
        implementor: implementor,
        option_builder: option_builder
      }
    end

    def self.get_implementor(name)
      @@register ||= {}
      @@register.fetch(name).fetch(:implementor)
    end

    def self.get_option_builder(name)
      @@register ||= {}
      @@register.fetch(name).fetch(:option_builder)
    end

    def self.load_all
      Dir[File.join(File.dirname(__FILE__), "commands/*.rb")].each do |plugin_file|
        load plugin_file
      end
    end
  end
end
