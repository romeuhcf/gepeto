require 'gepeto/log_list/log_message_list'

module Gepeto
  class Env
    attr_accessor :plugins, :app, :puppet, :repo, :errors, :warnings

    def initialize(plugins, app, puppet, repo)
      @plugins  = plugins
      @app      = app
      @puppet   = puppet
      @repo     = repo
      @errors   = LogMessageList.new
      @warnings = LogMessageList.new
    end
  end
end