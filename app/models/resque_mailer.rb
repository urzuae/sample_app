module Resque
  module Mailer
    class << self
      attr_accessor :default_queue_name
      def included(base)
        base.extend(ClassMethods)
      end
    end
    self.default_queue_name = 'mailer'
    module ClassMethods
      def queue
        ::Resque::Mailer.default_queue_name
      end
      def method_missing(method_name, *args)
        case method_name.id2name
        when /^deliver_([_a-z]\w*)\!/ then super(method_name, *args)
        when /^deliver_([_a-z]\w*)/ then ::Resque.enqueue(self, "#{method_name}!", *args)
        end
      end
      def perform(cmd, *args)
        send(cmd, *args)
      end
    end
  end
end