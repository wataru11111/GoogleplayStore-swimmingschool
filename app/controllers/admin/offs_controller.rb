class Admin::OffsController < ApplicationController
  def index
    if params[:search_date].present?
      search_date = Date.parse(params[:search_date]) rescue nil
      @offs = search_date ? Off.where("DATE(off_month) = ?", search_date) : Off.none
    else
      @offs = Off.all
    end
  end
end


