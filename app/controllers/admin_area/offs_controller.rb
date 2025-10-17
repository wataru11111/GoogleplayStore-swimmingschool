class AdminArea::OffsController < ApplicationController
  before_action :authenticate_admin!
  
  def index
    if params[:search_date].present?
      search_date = Date.parse(params[:search_date]) rescue nil
      @offs = search_date ? Off.where("DATE(off_month) = ?", search_date) : Off.none
    else
      @offs = Off.none
    end
  end

  def new
    @child = Child.find(params[:child_id])
    @off = Off.new
  end

  def create
    @off = Off.new(off_params)
    child = Child.find(@off.child_id)

    @off.level = child.level
    @off.contact_time1 = child.contact_time1
    @off.contact_time2 = child.contact_time2
    @off.contact_dey1 = child.contact_dey1
    @off.contact_dey2 = child.contact_dey2
    @off.last_name = child.last_name
    @off.first_name = child.first_name

    if @off.save
      redirect_to admin_area_customer_path(child.customer_id), notice: "お休みを登録しました。"
    else
      redirect_back fallback_location: admin_area_customer_path(child.customer_id), alert: "登録に失敗しました。"
    end
    end

  private

  def off_params
    params.require(:off).permit(:child_id, :off_month, :reason, :flag)
  end
end
