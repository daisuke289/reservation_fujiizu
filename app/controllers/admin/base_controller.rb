class Admin::BaseController < ApplicationController
  before_action :authenticate_admin
  
  layout 'admin'
  
  private
  
  def current_date
    @current_date ||= Date.current
  end
  
  def tomorrow_date
    @tomorrow_date ||= Date.current.tomorrow
  end
end