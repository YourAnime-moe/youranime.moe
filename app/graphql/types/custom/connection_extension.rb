module Types
  module Custom
    class ConnectionExtension < GraphQL::Schema::Field::ConnectionExtension
      def apply
        super
        field.argument :first, "Int", "Returns the first _n_ elements from the list.", required: true
      end
    end
  end
end
