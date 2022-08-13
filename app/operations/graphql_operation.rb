class GraphqlOperation < ApplicationOperation
  property :variables, accepts: Hash, default: -> { Hash.new }
  property :context, accepts: Hash, default: -> { Hash.new }

  attr_reader :result

  before do
    Rails.logger.info("[#{self.class.name}] variable=#{variables} context=#{context}")
  end

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
