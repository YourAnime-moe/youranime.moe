module Anilist
  class Result
    attr_reader :graphql_result

    def initialize(graphql_result)
      @graphql_result = graphql_result
    end

    def ok?
      !errored?
    end

    def errored?
      @graphql_result.errors.any?
    end

    def data
      @graphql_result.data
    end

    def to_h
      @graphql_result.to_h
    end

    def raw
      to_h
    end

    def inspect
      [
        "#<#{self.class.name}:#{self.object_id}>",
        "[#{ok? ? "OK" : "ERRORED"}]",
        "@data=#{data&.inspect}",
      ].join(" ")
    end
  end
end
