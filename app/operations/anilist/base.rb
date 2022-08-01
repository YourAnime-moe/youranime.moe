module Anilist
  class Base < GraphqlOperation
    def client
      Anilist::Client
    end
  end
end
