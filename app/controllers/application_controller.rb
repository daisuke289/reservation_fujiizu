class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  protected
  
  # 管理画面用の基本認証
  def authenticate_admin
    return true if Rails.env.test? # テスト環境では認証をスキップ
    
    username = ENV['BASIC_AUTH_USER'] || 'admin'
    password = ENV['BASIC_AUTH_PASSWORD'] || 'password'
    
    authenticate_or_request_with_http_basic('Admin Area') do |provided_username, provided_password|
      # 定数時間での比較でタイミング攻撃を防ぐ
      ActiveSupport::SecurityUtils.secure_compare(provided_username, username) &&
        ActiveSupport::SecurityUtils.secure_compare(provided_password, password)
    end
  end
end
