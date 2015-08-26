require 'gepeto/log_list/log_message'

module Gepeto
  class LogMessageList < Array
    def add(*args)
      self << LogMessage.new(*args)
    end
  end
end