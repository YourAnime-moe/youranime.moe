class IssuesController < AuthenticatedController

  before_action {
    @additional_main_class = 'no-margin no-padding'
  }

  def new
    set_title before: t('issues.title')
  end

  def open
  end

  def index
    set_title before: t('issues.all')
  end

  def close
  end
end
