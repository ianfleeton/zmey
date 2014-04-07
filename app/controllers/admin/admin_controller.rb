class Admin::AdminController < ApplicationController
  before_action :admin_or_manager_required

  layout 'admin'

  def index
  end
end
