class Public::HomeController < ApplicationController
  def index
    # セッションをクリア（新しい予約プロセスの開始）
    session[:reservation] = {}
  end
end