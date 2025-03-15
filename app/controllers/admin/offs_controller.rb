class Admin::OffsController < ApplicationController
  def index
    if params[:search_date].present?
      # search_date を Date 型に変換
      search_date = Date.strptime(params[:search_date], "%Y-%m-%d") rescue nil
      @offs = search_date ? Off.where(off_month: search_date) : Off.none
    else
      @offs = Off.all
    end
  end
end

