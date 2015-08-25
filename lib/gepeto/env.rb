require 'gepeto/error_list'
module Gepeto
  class Env
    attr_accessor :plugins, :app, :puppet, :repo, :errors

    def initialize(plugins, app, puppet, repo)
      @plugins = plugins
      @app     = app
      @puppet  = puppet
      @repo    = repo
      @errors  = ErrorList.new
    end
  end
end
