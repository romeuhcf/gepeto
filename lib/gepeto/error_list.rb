module Gepeto
  class Error
    attr_accessor :scope, :file, :content, :lineno, :message
    def initialize(scope, file, content, lineno, message)
      @scope   = scope
      @file    = file
      @content = content
      @lineno  = lineno
      @message = message
    end
  end

  class ErrorList < Array
    def add(*args)
      self << Error.new(*args)
    end
  end
end


