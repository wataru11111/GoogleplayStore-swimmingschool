class Admin::TransfersController < ApplicationController
  before_action :authenticate_admin!

  def new
    @child = Child.find(params[:child_id])
    @transfer = Transfer.new
  end

  def create
  @transfer = Transfer.new(transfer_params)

  if @transfer.save(context: :admin) # ← ✅ バリデーションスキップ
    redirect_to admin_customer_path(@transfer.child.customer_id), notice: "振替日を登録しました。"
  else
    redirect_back fallback_location: admin_customer_path(@transfer.child.customer_id), alert: "登録に失敗しました。"
  end
end


  private

  def transfer_params
    params.require(:transfer).permit(
      :child_id, :transfer_date, :transfer_time, :level, :contact_dey,
      :last_name, :first_name, :telephone_number, :off_id
    )
  end
end

