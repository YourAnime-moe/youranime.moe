class ApplicationController < ActionController::Base
  helper Webpacker::Helper
  
  def test
    @shows = Show.all
  end
end
