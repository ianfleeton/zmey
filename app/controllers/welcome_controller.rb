class WelcomeController < ApplicationController
  before_filter :require_website

  def index
  end
end