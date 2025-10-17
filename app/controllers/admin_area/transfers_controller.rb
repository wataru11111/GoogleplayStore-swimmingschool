class AdminArea::TransfersController < ApplicationController
  before_action :authenticate_admin!

  def new
    if params[:customer_id].present?
      @customer = Customer.find(params[:customer_id])
      @children = @customer.children
      @transfer = Transfer.new
      @transfer.customer_id = @customer.id
    elsif params[:child_id].present?
      @child = Child.find(params[:child_id])
      @customer = @child.customer
      @transfer = Transfer.new
      @transfer.customer_id = @customer.id
      @transfer.child_id = @child.id
    else
      redirect_to admin_area_customers_path, alert: "無効なアクセスです。"
      return
    end
  end

  def create
    @transfer = Transfer.new(transfer_params)
    @customer = Customer.find(@transfer.customer_id)

    if @transfer.save
      redirect_to admin_area_customers_path, notice: "振替登録が完了しました。"
    else
      if @transfer.child_id.present?
        @child = Child.find(@transfer.child_id)
      else
        @children = @customer.children
      end
      render :new
    end
  end

  private

  def transfer_params
    params.require(:transfer).permit(
      :customer_id, :child_id, :original_date, :transfer_date,
      :original_time, :transfer_time, :reason, :status
    )
  end
end
