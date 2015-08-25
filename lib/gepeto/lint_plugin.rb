module Gepeto
  class LintPlugin
    @@plugins = []

    def self.register(implementation)
      @@plugins << implementation
    end

    def self.inherited(base)
      register(base)
    end

    def self.all
      @@plugins.map do |plugin|
        if plugin.respond_to? :call
          plugin
        elsif plugin.is_a?(Class)
          plugin.new
        end
      end
    end
  end
end
