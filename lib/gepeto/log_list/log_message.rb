module Gepeto
  class LogMessage
    attr_accessor :scope, :file, :content, :lineno, :message
    def initialize(scope, file, content, lineno, message)
      @scope   = scope
      @file    = file
      @content = content
      @lineno  = lineno
      @message = message
    end
  end
end