# frozen_string_literal: true
class AdminSchema < GraphQL::Schema
  default_max_page_size(20)

  mutation(Admin::MutationType)
  query(Admin::QueryType)

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  # Add built-in connections for pagination
  use GraphQL::Pagination::Connections
end
