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


  # G_ADMIN_OFF_MANAGEMENT_20261119
  before_action :load_manageable_off, only: [:edit, :update, :destroy]

  def edit
    # @off と @customer は load_manageable_off で設定済み
  end

  def update
    selected_date = begin
      Date.iso8601(params.dig(:off, :off_month).to_s)
    rescue Date::Error, TypeError
      nil
    end

    if selected_date.nil?
      flash.now[:alert] = "お休み日を正しく入力してください。"
      render :edit, status: :unprocessable_entity
      return
    end

    error = admin_off_date_error(selected_date, @off.child)
    if error
      flash.now[:alert] = error
      render :edit, status: :unprocessable_entity
      return
    end

    @off.off_month = selected_date
    if @off.save(context: :public)
      redirect_to admin_area_customer_path(@customer, anchor: "admin-child-#{@off.child_id}"),
        notice: "お休み日を変更しました。"
    else
      flash.now[:alert] = @off.errors.full_messages.join("、")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @off.with_lock do
      if @off.flag != 0 || @off.expired? || @off.transfers.exists?
        raise ActiveRecord::RecordNotDestroyed, "振替済み・期限切れのお休みは削除できません。"
      end
      @off.destroy!
    end

    redirect_to admin_area_customer_path(@customer, anchor: "admin-child-#{@off.child_id}"),
      notice: "お休みを削除しました。"
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid => e
    redirect_to admin_area_customer_path(@customer, anchor: "admin-child-#{@off.child_id}"),
      alert: e.message.presence || "お休みを削除できませんでした。"
  end

  private


  # 編集・削除を許すのは会員側と同じ「未振替・未期限切れ」のみ。
  def load_manageable_off
    @off = Off.includes(:transfers, :child).find(params[:id])
    @customer = @off.child.customer
    if @off.flag != 0 || @off.expired? || @off.transfers.any?
      redirect_to admin_area_customer_path(@customer, anchor: "admin-child-#{@off.child_id}"),
        alert: "振替済み・期限切れのお休みは変更や削除ができません。"
    end
  end

  def admin_off_date_error(date, child)
    return "過去の日付には変更できません。" if date < Date.current

    # 現行のお休み登録可能最終日を維持
    last_value = Setting.find_by(key: "available_off_day")&.value
    return "まだスケジュールが未定です。" if last_value.blank?

    last_day = begin
      Date.iso8601(last_value.to_s)
    rescue Date::Error, TypeError
      nil
    end
    return "登録可能な最終日の設定が不正です。" if last_day.nil?
    return "登録可能な最終日を過ぎています。" if date > last_day

    weekday = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日][date.wday]
    contract_days = [child.contact_dey1, child.contact_dey2].compact.map(&:strip).uniq
    unless contract_days.include?(weekday) || ScheduleOverrides.off_for?(date, child)
      return "契約曜日（#{contract_days.join('・')}）の日付を選択してください。"
    end

    # 管理者側の不可日設定を無視して変更できないようにする
    disabled_days = Setting.find_by(key: "disabled_off_days")&.value.to_s
    if disabled_days.include?(date.iso8601)
      return "この日はお休み登録できない日付です。"
    end

    # 会員側が使用している「時間指定の休校日」判定を共用
    public_checker = Public::OffsController.new
    if public_checker.send(:off_date_disabled_by_slots?, date)
      return "この日はお休み登録できない日付です。"
    end

    nil
  end

  def off_params
    params.require(:off).permit(:child_id, :off_month, :reason, :flag)
  end
end
