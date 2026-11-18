class Public::DateController < ApplicationController
  before_action :authenticate_customer!
  def new
    @date = Transfer.new
  end

  def create
  @date = Transfer.new(transfer_params)

    # A④ 必須項目チェック
    if current_customer.children.none?
      @date.errors.add(:base, "会員登録をお願いします")
    else
      required_fields = {
        child_id: "お子様のお名前",
        off_id: "お休み日",
        transfer_date: "振替日",
        level: "クラス",
        transfer_time: "振替時間"
      }

      required_fields.each do |field, label|
        if params.dig(:transfer, field).blank?
          @date.errors.add(
            :base,
            "#{label}が記入不足で登録できません"
          )
        end
      end
    end

    if @date.errors.any?
      @children = current_customer.children.order(:id).to_a

      @offs = @children.flat_map do |child|
        child.offs.where(flag: 0).map { |off| [child.id, off] }
      end

      return render :index, status: :unprocessable_entity
    end


  # お子さんを検索
  child = current_customer.children.find_by(
    id: params.dig(:transfer, :child_id)
  )

  unless child
    flash[:alert] = current_customer.children.exists? ?
      "お子様を選択してください。" :
      "会員登録をお願いします"
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
    @date.last_name = child.last_name
    @date.first_name = child.first_name
    @date.telephone_number = current_customer.telephone_number
    @date.off_id = off.id
   @date.transfer_date = Date.parse(params[:transfer][:transfer_date]) rescue nil

   if @date.transfer_date.nil?
     flash[:alert] = "無効な振替日が選択されました。"
     redirect_to date_index_path and return
   end

  # 振替曜日は日付からサーバー側で確定する
   @date.contact_dey = TransferCalendar.day_for(@date.transfer_date)

   unless @date.contact_dey
     flash[:alert] = "この日は振替できません。土日または祝日を選択してください。"
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

   unless TransferCalendar.allowed_times_for(@date.contact_dey, @date.level, date: @date.transfer_date).include?(@date.transfer_time)
     flash[:alert] = "振替時間を正しく選択してください。"
     redirect_to date_index_path and return
   end
  
    # === 新しい時間帯ベースのチェック ===
    disabled_transfer_days = Setting.find_by(key: "disabled_transfer_days")&.value.to_s
      .split(/[,、，\s]+/)
    if disabled_transfer_days.include?(@date.transfer_date.iso8601)
      flash[:alert] = "この日は振替登録不可日に設定されています。"
      redirect_to date_index_path and return
    end

    if check_disabled_transfer_slot(@date.transfer_date, @date.transfer_time)
      flash[:alert] = "この日時は振替できません。別の日時をお選びください。"
      redirect_to date_index_path and return
    end

   # A3_SLOT_CAPACITY_20261118: サーバー側で満員を再確認し保存
   saved = false
   is_full = false
   already_registered = false

   ActiveRecord::Base.transaction do
     # 複数会員の同時登録を順番に処理するため、共通設定行をロック
     Setting.where(key: "available_transfer_day").lock.first!

     # A_DUPLICATE_TRANSFER_GUARD_20261118
     # 別のお休みを使っても、同じ子・同じ振替日・同じ時間は二重登録できない。
     # お休み日と振替日が同日かどうかは判定しない（従来仕様を維持）。
     already_registered = Transfer.exists?(
       child_id: child.id,
       transfer_date: @date.transfer_date,
       transfer_time: @date.transfer_time
     )

     if already_registered
       # 二重登録なら保存しない
     elsif TransferCalendar.registration_count(
       @date.transfer_date, @date.transfer_time, @date.level
     ) >= TransferCalendar::CAPACITY
       is_full = true
     else
       saved = @date.save(context: :public)
       off.update!(flag: 1) if saved
     end
   end

   if already_registered
     flash[:alert] = "この振替日・時間は既に登録済みです。別の日時を選択してください。"
     redirect_to date_index_path and return
   elsif is_full
     flash[:alert] = "選択した振替時間は満員です。別の時間をお選びください。"
     redirect_to date_index_path and return
   elsif saved
     flash[:notice] = "振替登録が完了しました。"
     redirect_to dates_completion_path(id: @date.id)
   else
     @children = current_customer.children.order(:id).to_a
     @offs = @children.flat_map do |child|
       child.offs.where(flag: 0).map { |off| [child.id, off] }
     end
     render :index, status: :unprocessable_entity
   end
 end

  # A3_SLOT_CAPACITY_20261118
  # 日付・クラスから選べる時間と残り人数を返す
  def slot_availability
    date = Date.iso8601(params[:date].to_s)
    level = params[:level].to_s
    day = TransferCalendar.day_for(date)

    limit = Setting.find_by(key: "available_transfer_day")&.value
    within_period = limit.blank? || date <= Date.iso8601(limit)
    disabled_days = Setting.find_by(key: "disabled_transfer_days")&.value.to_s
      .split(/[,、，\s]+/)

    slots = []
    if date > Date.current && within_period && day &&
       !disabled_days.include?(date.iso8601)
      TransferCalendar.allowed_times_for(day, level, date: date).each do |time|
        next if check_disabled_transfer_slot(date, time)

        used = TransferCalendar.registration_count(date, time, level)
        remaining = [TransferCalendar::CAPACITY - used, 0].max
        slots << {
          time: time,
          remaining: remaining,
          capacity: TransferCalendar::CAPACITY,
          full: remaining.zero?
        }
      end
    end

    response.headers["Cache-Control"] = "no-store"
    render json: { day: day, slots: slots }
  rescue ArgumentError
    render json: { day: nil, slots: [] }, status: :unprocessable_entity
  end

  def index
    @date = Transfer.new
    @children = current_customer.children.order(:id).to_a
    @offs = @children.flat_map do |child|
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
      :child_id, :transfer_date, :level,
      :contact_dey, :transfer_time, :off_id
    )
  end
end

