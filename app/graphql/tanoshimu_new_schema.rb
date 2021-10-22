# frozen_string_literal: true
class TanoshimuNewSchema < GraphQL::Schema
  default_max_page_size(20)

  mutation(Types::MutationType)
  query(Queries::Root)

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  # Add built-in connections for pagination
  use GraphQL::Pagination::Connections
end
