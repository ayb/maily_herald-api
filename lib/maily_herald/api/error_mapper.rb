module MailyHerald
  module Api
    class ErrorMapper
      attr_reader :object

      # Class instance used to get mapped errors for ActiveRecord objects.
      #
      # @param object [ActiveRecord::Base]
      def initialize object
        @object = object
      end

      # Get hash of mapped errors of object.
      def errors
        object.errors.details.inject({}) do |hash, e|
          attribute = e[0]
          error_type = e[1].first[:error]

          hash[attribute] = error_type.match(/locked/) ? "locked" : error_type
          hash
        end
      end
    end
  end
end