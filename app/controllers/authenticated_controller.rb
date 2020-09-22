# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  layout 'authenticated'
  include EpisodesHelper

  before_action :ensure_logged_in!
end
