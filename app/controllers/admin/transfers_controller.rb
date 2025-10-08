class Admin::TransfersController < ApplicationController
  before_action :authenticate_admin!

  def new
    @child = Child.find(params[:child_id])
    @transfer = Transfer.new(
      child_id: @child.id,
      level: @child.level,
      transfer_time: @child.contact_time1.presence || @child.contact_time2,
      transfer_date: Date.current
    )
  end

  def create
    @transfer = Transfer.new(transfer_params)

    # 不足項目を子どもの情報から補完（管理者登録用）
    child = @transfer.child || Child.find_by(id: params.dig(:transfer, :child_id))
    if child
      @transfer.last_name       ||= child.last_name
      @transfer.first_name      ||= child.first_name
      @transfer.level           ||= child.level
      @transfer.telephone_number ||= child.telephone_number.presence || child.customer&.telephone_number
      @transfer.transfer_time   ||= child.contact_time1.presence || child.contact_time2
    end

    # contact_dey が未指定なら、振替日から日本語曜日名を採用
    if @transfer.transfer_date.present? && @transfer.contact_dey.blank?
      %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日].tap do |jp|
        @transfer.contact_dey = jp[@transfer.transfer_date.wday]
      end
    end

    # DBのNOT NULLカラムは最低限埋める（バリデーションは緩く、未入力なら画面に戻す）
    required = %i[transfer_date transfer_time level contact_dey last_name first_name]
    if required.any? { |a| @transfer.send(a).blank? }
      return redirect_back fallback_location: admin_customer_path(child&.customer_id || @transfer.child&.customer_id), alert: "必須項目が未入力です。日付・時間・レベルを入力してください。"
    end

    if @transfer.save(context: :admin)
      redirect_to admin_customer_path(@transfer.child.customer_id), notice: "振替日を登録しました。"
    else
      redirect_back fallback_location: admin_customer_path(child&.customer_id || @transfer.child&.customer_id), alert: "登録に失敗しました。"
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

