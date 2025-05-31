class Public::DateController < ApplicationController
  def new
    @date = Transfer.new
  end

  def create
  @date = Transfer.new(transfer_params)

  # お子さんを検索
  child = current_customer.children.find_by(
    first_name: params[:transfer][:first_name],
    last_name: params[:transfer][:last_name]
  )

  unless child
    flash[:alert] = "指定されたお子さんが見つかりませんでした。"
    redirect_to date_index_path and return
  end

  # お休みデータを検索（flag: 0 かつ child_id 一致するもの）
  off = child.offs.where(flag: 0).first
  unless off
    flash[:alert] = "振替に必要なお休みが見つかりませんでした。"
    redirect_to date_index_path and return
  end

  # Transferオブジェクトにデータを設定
   @date.child_id = child.id
   @date.off_id = off.id
   @date.transfer_date = Date.parse(params[:transfer][:transfer_date]) rescue nil

   if @date.transfer_date.nil?
     flash[:alert] = "無効な振替日が選択されました。"
     redirect_to date_index_path and return
   end

  # ✅ 振替日が許可された月か確認
    limit_day = Setting.find_by(key: 'available_transfer_day')&.value
   if limit_day.present? && @date.transfer_date > Date.parse(limit_day)
     flash[:alert] = "まだスケジュールが未定です。"
     redirect_to date_index_path and return
   end


  # 前日までしか登録できないチェック
   if @date.transfer_date <= Date.today
     flash[:alert] = "振替は前日までに登録してください。当日や過去の日付は選べません。"
     redirect_to date_index_path and return
   end

  @date.transfer_time = params[:transfer][:transfer_time]

  # 振替登録の保存処理
  if @date.save
    off.update(flag: 1)
    flash[:notice] = "振替登録が完了しました。"
    redirect_to dates_completion_path(id: @date.id)
  else
    flash[:alert] = @date.errors.full_messages.join(", ")
    render :index
  end
end

  
  

  def index
    @date = Transfer.new
  end

  def confirmation
    @dates = Transfer.joins(:child)
                     .where(children: { customer_id: current_customer.id })
                     .order(transfer_date: :desc) # 振替日を降順で並べ替え
  end
  

  def completion
    @dates = Transfer.find(params[:id])
  end

  private

  def transfer_params
    params.require(:transfer).permit(
      :last_name, :first_name, :transfer_date, :level, :contact_dey, 
      :transfer_time, :telephone_number,
    )
  end
end
