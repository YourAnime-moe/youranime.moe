class ApplicationController < ActionController::API
  protected

  def render_api(data, **kwargs)
    render(json: data, **kwargs)
  end
end
