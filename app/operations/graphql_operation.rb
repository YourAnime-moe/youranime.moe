class GraphqlOperation < ApplicationOperation
  property :variables, accepts: Hash, default: -> { Hash.new }
  property :context, accepts: Hash, default: -> { Hash.new }

  attr_reader :result

  protected

  def client
    raise NotImplementedError
  end

  def query
    raise NotImplementedError
  end

  def graphql_params
    {
      variables: variables,
      context: context,
    }
  end
end
