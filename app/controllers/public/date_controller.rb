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
  off = Off.find_by(id: params[:transfer][:off_id], child_id: child.id, flag: 0)

  unless off
    flash[:alert] = "選択されたお休み日が無効です。"
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
  
    # === 新しい時間帯ベースのチェック ===
    if check_disabled_transfer_slot(@date.transfer_date, @date.transfer_time)
      flash[:alert] = "この日時は振替できません。別の日時をお選びください。"
      redirect_to date_index_path and return
    end

  # ✅ 時間帯 × レベルの組み合わせが3人以上かチェック
     count = Transfer.where(
       transfer_date: @date.transfer_date,
       transfer_time: @date.transfer_time,
       level: @date.level
     ).count

   if count >= 3
     flash[:alert] = "#{@date.transfer_time} の #{@date.level} クラスは定員に達しています。別の時間をお選びください。"
     redirect_to date_index_path and return
   end  


  # 振替登録の保存処理
  if @date.save(context: :public)  # ← ✅ 会員にはバリデーション適用
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
    @offs = current_customer.children.flat_map do |child|
    child.offs.where(flag: 0).map { |off| [child.id, off] }
   end
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

  def check_disabled_transfer_slot(transfer_date, transfer_time)
    slots_json = Setting.find_by(key: 'disabled_transfer_slots')&.value
    return false if slots_json.blank?
    
    begin
      slots = JSON.parse(slots_json)
    rescue JSON::ParserError
      return false
    end
    
    date_str = transfer_date.strftime('%Y-%m-%d')
    
    slots.each do |slot|
      next unless slot['date'] == date_str
      
      # 全休の場合はその日全体が不可
      if slot['type'] == 'all_day'
        return true
      end
      
      # 時間指定の場合は時間範囲をチェック
      if slot['type'] == 'time_range' && transfer_time.present?
        slot_start = Time.parse("#{date_str} #{slot['start_time']}")
        slot_end = Time.parse("#{date_str} #{slot['end_time']}")
        
        # transfer_timeが文字列の場合（例: "11:00"）
        transfer_datetime = Time.parse("#{date_str} #{transfer_time}")
        
        # 指定時間が不可能時間帯に含まれているかチェック
        if transfer_datetime >= slot_start && transfer_datetime < slot_end
          return true
        end
      end
    end
    
    false
  end

  def transfer_params
    params.require(:transfer).permit(
      :last_name, :first_name, :transfer_date, :level, :contact_dey, 
      :transfer_time, :telephone_number, :off_id
    )
  end
end

