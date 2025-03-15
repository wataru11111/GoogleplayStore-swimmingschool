class Admin::OffsController < ApplicationController
  def index
    if params[:search_date].present?
      begin
        search_date = Date.parse(params[:search_date].tr("/", "-")) # "/"を"-"に統一し、Date型に変換
        @offs = Off.where("DATE(off_month) = ?", search_date) # DATE関数を使って検索
      rescue ArgumentError
        @offs = [] # 日付のパースに失敗した場合は空配列を返す
      end
    else
      @offs = Off.all
    end
  end
end
